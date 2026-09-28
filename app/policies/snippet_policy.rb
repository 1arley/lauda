class SnippetPolicy < ApplicationPolicy
  def index? = true
  def create? = professional_or_above?
  def update? = professional_or_above?
  def destroy? = tenant_admin_or_above?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(tenant_id: user.tenant_id)
    end
  end

  private

  def same_tenant?
    record.tenant_id == user.tenant_id
  end

  def professional_or_above?
    same_tenant? && (user.saas_admin? || user.tenant_admin? || user.professional?)
  end

  def tenant_admin_or_above?
    same_tenant? && (user.saas_admin? || user.tenant_admin?)
  end
end
