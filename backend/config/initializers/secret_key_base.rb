Rails.application.config.secret_key_base = ENV.fetch("SECRET_KEY_BASE") {
  "dev_secret_key_base_for_healthcare_appointment_system_12345678901234567890"
}
