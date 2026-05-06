class Appointment < ApplicationRecord
  STATUSES = %w[Scheduled Confirmed InProgress Completed Cancelled].freeze

  belongs_to :patient, class_name: "PatientProfile"
  belongs_to :doctor, class_name: "DoctorProfile"
  has_one :medical_record, dependent: :destroy

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :not_cancelled, -> { where.not(status: "Cancelled") }
end
