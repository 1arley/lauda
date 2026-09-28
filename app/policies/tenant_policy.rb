class TenantPolicy < ApplicationPolicy
  def show? = admin_or_above?
  def update? = user.saas_admin?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.saas_admin?
        scope.all
      else
        scope.where(id: user.tenant_id)
      end
    end
  end

  private

  def admin_or_above?
    user.saas_admin? || user.tenant_admin?
  end
end
