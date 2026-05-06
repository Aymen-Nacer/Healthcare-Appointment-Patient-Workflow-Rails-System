module Api
  class AuditLogsController < ApplicationController
    before_action :authenticate!
    before_action -> { require_role!("Admin") }

    def index
      logs = AuditLog.all

      if params[:entityId].present?
        logs = logs.where(entity_id: params[:entityId])
      end

      if params[:action_filter].present?
        logs = logs.where("action ILIKE ?", "%#{params[:action_filter]}%")
      end

      if params[:date].present?
        day = Date.parse(params[:date])
        logs = logs.where(timestamp: day.beginning_of_day..day.end_of_day)
      end

      logs = logs.order(timestamp: :desc)

      render json: logs.map { |l|
        {
          id: l.id,
          action: l.action,
          performedByUserId: l.performed_by_user_id,
          timestamp: l.timestamp.iso8601,
          entityName: l.entity_name,
          entityId: l.entity_id,
          metadata: l.metadata
        }
      }
    end
  end
end
