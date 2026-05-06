class AuditLogService
  def self.log(action:, performed_by_user_id:, entity_name:, entity_id:, metadata: nil)
    AuditLog.create!(
      action: action,
      performed_by_user_id: performed_by_user_id,
      entity_name: entity_name,
      entity_id: entity_id,
      metadata: metadata,
      timestamp: Time.current
    )
  end
end
