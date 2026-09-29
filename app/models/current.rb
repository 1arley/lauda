class Current < ActiveSupport::CurrentAttributes
  attribute :tenant_id, :user_id, :ip_address
end
