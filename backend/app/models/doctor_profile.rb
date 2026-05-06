class DoctorProfile < ApplicationRecord
  belongs_to :user
  has_many :appointments, foreign_key: :doctor_id, dependent: :restrict_with_error

  validates :specialty, presence: true
end
