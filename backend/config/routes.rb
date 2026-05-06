Rails.application.routes.draw do
  namespace :api do
    post "auth/register", to: "auth#register"
    post "auth/login",    to: "auth#login"

    resources :doctors, only: [:index]

    resources :appointments, only: [:index, :create] do
      member do
        patch :status, to: "appointments#update_status"
      end
    end

    resources :medical_records, only: [:create], path: "medical-records"
    get "medical-records/:appointment_id", to: "medical_records#show_by_appointment"

    resources :audit_logs, only: [:index], path: "audit-logs"
  end
end
