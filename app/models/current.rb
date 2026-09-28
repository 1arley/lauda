class Current < ActiveSupport::CurrentAttributes
  attribute :tenant_id, :user_id, :ip_address

  def tenant
    return @tenant if defined?(@tenant)

    @tenant = Tenant.find_by(id: tenant_id)
  end

  def user
    return @user if defined?(@user)

    @user = User.find_by(id: user_id)
  end
end
