class ReportTemplatePolicy < ApplicationPolicy
  def index? = true
  def show? = same_tenant?
  def create? = tenant_admin_or_above?
  def update? = tenant_admin_or_above?
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

  def tenant_admin_or_above?
    same_tenant? && (user.saas_admin? || user.tenant_admin?)
  end
end
