module Api
  class MedicalRecordsController < ApplicationController
    before_action :authenticate!
    before_action -> { require_role!("Doctor") }, only: [:create]

    def create
      appointment = Appointment.includes(patient: :user, doctor: :user)
        .includes(:medical_record)
        .find_by(id: params[:appointmentId])

      unless appointment
        return render json: { message: "Appointment with ID #{params[:appointmentId]} not found." }, status: :not_found
      end

      unless appointment.status == "InProgress"
        return render json: { message: "Medical records can only be created when the appointment is InProgress." }, status: :conflict
      end

      if appointment.medical_record.present?
        return render json: { message: "A medical record already exists for this appointment." }, status: :conflict
      end

      doctor_profile = DoctorProfile.find_by(user_id: current_user_id)
      unless doctor_profile
        return render json: { message: "Doctor profile not found." }, status: :bad_request
      end

      unless appointment.doctor_id == doctor_profile.id
        return render json: { message: "You can only create medical records for your own appointments." }, status: :forbidden
      end

      record = MedicalRecord.create!(
        appointment: appointment,
        diagnosis: params[:diagnosis],
        notes: params[:notes] || ""
      )

      AuditLogService.log(
        action: "MedicalRecordCreated",
        performed_by_user_id: current_user_id,
        entity_name: "MedicalRecord",
        entity_id: record.id,
        metadata: "AppointmentId=#{appointment.id}, Diagnosis=#{params[:diagnosis]}"
      )

      render json: medical_record_response(record, appointment), status: :created
    end

    def show_by_appointment
      record = MedicalRecord.includes(appointment: [{ patient: :user }, { doctor: :user }])
        .find_by(appointment_id: params[:appointment_id])

      unless record
        return render json: { message: "Medical record for appointment ID #{params[:appointment_id]} not found." }, status: :not_found
      end

      appointment = record.appointment

      if current_user_role == "Patient"
        patient_profile = PatientProfile.find_by(user_id: current_user_id)
        if patient_profile.nil? || appointment.patient_id != patient_profile.id
          return render json: { message: "Access denied to this medical record." }, status: :forbidden
        end
      elsif current_user_role == "Doctor"
        doctor_profile = DoctorProfile.find_by(user_id: current_user_id)
        if doctor_profile.nil? || appointment.doctor_id != doctor_profile.id
          return render json: { message: "Access denied to this medical record." }, status: :forbidden
        end
      end

      render json: medical_record_response(record, appointment)
    end

    private

    def medical_record_response(record, appointment)
      {
        id: record.id,
        appointmentId: record.appointment_id,
        patientName: appointment.patient&.user&.name || "",
        doctorName: appointment.doctor&.user&.name || "",
        diagnosis: record.diagnosis,
        notes: record.notes,
        createdAt: record.created_at.iso8601
      }
    end
  end
end
