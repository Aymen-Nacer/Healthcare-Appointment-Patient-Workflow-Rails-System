class AuditLog < ApplicationRecord
  validates :action, presence: true
  validates :performed_by_user_id, presence: true
  validates :entity_name, presence: true
  validates :entity_id, presence: true
end
