return if User.any?

admin = User.create!(
  name: "Admin User",
  email: "admin@healthcare.com",
  password_digest: BCrypt::Password.create("Admin@123"),
  role: "Admin"
)

doctor1 = User.create!(
  name: "Dr. Alice Smith",
  email: "alice.smith@healthcare.com",
  password_digest: BCrypt::Password.create("Doctor@123"),
  role: "Doctor"
)

doctor2 = User.create!(
  name: "Dr. Bob Johnson",
  email: "bob.johnson@healthcare.com",
  password_digest: BCrypt::Password.create("Doctor@123"),
  role: "Doctor"
)

patient1 = User.create!(
  name: "Carol White",
  email: "carol.white@email.com",
  password_digest: BCrypt::Password.create("Patient@123"),
  role: "Patient"
)

patient2 = User.create!(
  name: "David Brown",
  email: "david.brown@email.com",
  password_digest: BCrypt::Password.create("Patient@123"),
  role: "Patient"
)

DoctorProfile.create!(user: doctor1, specialty: "Cardiology")
DoctorProfile.create!(user: doctor2, specialty: "General Practice")

PatientProfile.create!(user: patient1)
PatientProfile.create!(user: patient2)

puts "Seed data created successfully."
