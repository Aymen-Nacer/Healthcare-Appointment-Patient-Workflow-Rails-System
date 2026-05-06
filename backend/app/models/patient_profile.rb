class PatientProfile < ApplicationRecord
  belongs_to :user
  has_many :appointments, foreign_key: :patient_id, dependent: :restrict_with_error
end
