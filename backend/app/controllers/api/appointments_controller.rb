module Api
  class AppointmentsController < ApplicationController
    before_action :authenticate!
    before_action -> { require_role!("Patient") }, only: [:create]
    before_action -> { require_role!("Admin", "Doctor") }, only: [:update_status]

    def index
      appointments = Appointment.includes(patient: :user, doctor: :user)

      case current_user_role
      when "Patient"
        patient_profile = PatientProfile.find_by(user_id: current_user_id)
        appointments = appointments.where(patient_id: patient_profile&.id)
      when "Doctor"
        doctor_profile = DoctorProfile.find_by(user_id: current_user_id)
        appointments = appointments.where(doctor_id: doctor_profile&.id)
      else
        appointments = appointments.where(doctor_id: params[:doctorId]) if params[:doctorId].present?
        appointments = appointments.where(patient_id: params[:patientId]) if params[:patientId].present?
      end

      appointments = appointments.order(start_time: :desc)
      render json: appointments.map { |a| appointment_response(a) }
    end

    def create
      start_time = begin
        Time.parse(params[:startTime].to_s)
      rescue ArgumentError
        return render json: { message: "Invalid start time format." }, status: :bad_request
      end

      end_time = begin
        Time.parse(params[:endTime].to_s)
      rescue ArgumentError
        return render json: { message: "Invalid end time format." }, status: :bad_request
      end

      if start_time <= Time.current
        return render json: { message: "Cannot book an appointment in the past." }, status: :bad_request
      end

      if end_time <= start_time
        return render json: { message: "EndTime must be after StartTime." }, status: :bad_request
      end

      patient_profile = PatientProfile.includes(:user).find_by(user_id: current_user_id)
      unless patient_profile
        return render json: { message: "Patient profile not found for the current user." }, status: :bad_request
      end

      doctor_profile = DoctorProfile.includes(:user).find_by(id: params[:doctorId])
      unless doctor_profile
        return render json: { message: "Doctor with ID #{params[:doctorId]} not found." }, status: :not_found
      end

      appointment = nil
      overlap_error = false

      Appointment.transaction do
        has_overlap = Appointment.not_cancelled
          .where(doctor_id: doctor_profile.id)
          .where("start_time < ? AND end_time > ?", end_time, start_time)
          .exists?

        if has_overlap
          overlap_error = true
          raise ActiveRecord::Rollback
        end

        appointment = Appointment.create!(
          patient_id: patient_profile.id,
          doctor_id: doctor_profile.id,
          start_time: start_time,
          end_time: end_time,
          status: "Scheduled"
        )

        AuditLogService.log(
          action: "AppointmentCreated",
          performed_by_user_id: current_user_id,
          entity_name: "Appointment",
          entity_id: appointment.id,
          metadata: "PatientId=#{patient_profile.id}, DoctorId=#{doctor_profile.id}, StartTime=#{start_time.utc.iso8601}"
        )
      end

      if overlap_error
        render json: { message: "The doctor already has an appointment during this time slot." }, status: :conflict
      else
        render json: appointment_response(appointment.reload), status: :created
      end
    end

    def update_status
      appointment = Appointment.includes({ patient: :user, doctor: :user }, :medical_record)
        .find_by(id: params[:id])

      unless appointment
        return render json: { message: "Appointment with ID #{params[:id]} not found." }, status: :not_found
      end

      if appointment.status == "Completed"
        return render json: { message: "Cannot modify a completed appointment." }, status: :bad_request
      end

      new_status = params[:newStatus].to_s

      unless valid_transition?(appointment.status, new_status, current_user_role)
        return render json: { message: "Transition from '#{appointment.status}' to '#{new_status}' is not allowed for role '#{current_user_role}'." }, status: :bad_request
      end

      if new_status == "Completed" && appointment.medical_record.nil?
        return render json: { message: "Cannot complete appointment without a medical record." }, status: :bad_request
      end

      if current_user_role == "Doctor"
        doctor_profile = DoctorProfile.find_by(user_id: current_user_id)
        if doctor_profile.nil? || doctor_profile.id != appointment.doctor_id
          return render json: { message: "You can only update appointments assigned to you." }, status: :forbidden
        end
      end

      previous_status = appointment.status
      appointment.status = new_status

      if params[:rowVersion].present?
        appointment.lock_version = params[:rowVersion].to_i
      end

      begin
        appointment.save!
      rescue ActiveRecord::StaleObjectError
        return render json: { message: "The appointment was modified by another user. Please refresh and try again." }, status: :conflict
      end

      AuditLogService.log(
        action: "AppointmentStatusChanged",
        performed_by_user_id: current_user_id,
        entity_name: "Appointment",
        entity_id: appointment.id,
        metadata: "From=#{previous_status}, To=#{new_status}"
      )

      render json: appointment_response(appointment.reload)
    end

    private

    def valid_transition?(current, next_status, role)
      allowed = {
        ["Scheduled", "Confirmed", "Admin"] => true,
        ["Scheduled", "Cancelled", "Admin"] => true,
        ["Confirmed", "Cancelled", "Admin"] => true,
        ["Confirmed", "InProgress", "Doctor"] => true,
        ["InProgress", "Completed", "Doctor"] => true
      }
      allowed[[current, next_status, role]] == true
    end

    def appointment_response(a)
      {
        id: a.id,
        patientId: a.patient_id,
        patientName: a.patient&.user&.name || "",
        doctorId: a.doctor_id,
        doctorName: a.doctor&.user&.name || "",
        doctorSpecialty: a.doctor&.specialty || "",
        startTime: a.start_time.iso8601,
        endTime: a.end_time.iso8601,
        status: a.status,
        rowVersion: a.lock_version
      }
    end
  end
end
