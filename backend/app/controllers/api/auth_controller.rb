module Api
  class AuthController < ApplicationController
    def register
      if User.exists?(email: params[:email])
        return render json: { message: "Email is already registered." }, status: :bad_request
      end

      role = params[:role].to_s
      unless %w[Admin Doctor Patient].include?(role)
        return render json: { message: "Invalid role." }, status: :bad_request
      end

      user = User.new(
        name: params[:name],
        email: params[:email],
        password_digest: BCrypt::Password.create(params[:password]),
        role: role
      )

      unless user.save
        return render json: { message: user.errors.full_messages.join(", ") }, status: :bad_request
      end

      if user.Doctor?
        DoctorProfile.create!(user: user, specialty: "General")
      elsif user.Patient?
        PatientProfile.create!(user: user)
      end

      render json: auth_response(user), status: :created
    end

    def login
      user = User.find_by(email: params[:email])
      if user.nil? || !BCrypt::Password.new(user.password_digest).is_password?(params[:password])
        return render json: { message: "Invalid email or password." }, status: :unauthorized
      end

      render json: auth_response(user), status: :ok
    end

    private

    def auth_response(user)
      {
        token: JwtService.encode(user),
        name: user.name,
        email: user.email,
        role: user.role,
        userId: user.id
      }
    end
  end
end
