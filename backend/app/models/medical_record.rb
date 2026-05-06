class MedicalRecord < ApplicationRecord
  belongs_to :appointment

  validates :diagnosis, presence: true
  validates :appointment_id, uniqueness: true
end
