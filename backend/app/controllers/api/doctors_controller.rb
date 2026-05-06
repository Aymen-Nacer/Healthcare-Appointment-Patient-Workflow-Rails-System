module Api
  class DoctorsController < ApplicationController
    before_action :authenticate!

    def index
      doctors = DoctorProfile.includes(:user).map do |d|
        {
          doctorProfileId: d.id,
          userId: d.user_id,
          name: d.user.name,
          email: d.user.email,
          specialty: d.specialty
        }
      end

      render json: doctors
    end
  end
end
