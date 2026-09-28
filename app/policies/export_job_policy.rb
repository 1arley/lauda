class ExportJobPolicy < ApplicationPolicy
  def index? = true
  def show? = same_tenant?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(tenant_id: user.tenant_id)
    end
  end

  private

  def same_tenant?
    record.tenant_id == user.tenant_id
  end
end
