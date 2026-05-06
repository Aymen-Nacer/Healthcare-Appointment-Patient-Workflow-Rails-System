class JwtService
  SECRET_KEY = ENV.fetch("JWT_SECRET") { "SuperSecretKeyForHealthcareAppointmentSystem2024!MustBe32CharsMin" }
  ISSUER = ENV.fetch("JWT_ISSUER") { "HealthcareAppointmentSystem" }
  AUDIENCE = ENV.fetch("JWT_AUDIENCE") { "HealthcareAppointmentSystem" }
  EXPIRES_IN = ENV.fetch("JWT_EXPIRES_IN_MINUTES") { "60" }.to_i

  def self.encode(user)
    payload = {
      sub: user.id.to_s,
      email: user.email,
      name: user.name,
      role: user.role,
      userId: user.id,
      iss: ISSUER,
      aud: AUDIENCE,
      jti: SecureRandom.uuid,
      exp: EXPIRES_IN.minutes.from_now.to_i
    }
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(
      token, SECRET_KEY, true,
      algorithms: ["HS256"],
      iss: ISSUER,
      aud: AUDIENCE,
      verify_iss: true,
      verify_aud: true
    )
    decoded.first
  rescue JWT::DecodeError
    nil
  end
end
