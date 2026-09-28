Warden::Manager.after_set_user do |user, _auth, _opts|
  ActsAsTenant.current_tenant = user.tenant if user.respond_to?(:tenant_id) && user.tenant_id.present?
end

Warden::Manager.before_logout do |_user, _auth, _opts|
  ActsAsTenant.current_tenant = nil
end
