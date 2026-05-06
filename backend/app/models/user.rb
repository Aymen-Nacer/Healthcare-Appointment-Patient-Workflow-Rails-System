class User < ApplicationRecord
  has_secure_password validations: false

  enum role: { Admin: 0, Doctor: 1, Patient: 2 }

  has_one :doctor_profile, dependent: :destroy
  has_one :patient_profile, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true
  validates :role, presence: true
end
