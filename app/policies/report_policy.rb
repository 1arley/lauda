class ReportPolicy < ApplicationPolicy
  def index? = true
  def show? = same_tenant?
  def create? = professional_or_above?
  def update? = owner_or_admin? && !record.final?
  def finalize? = owner_or_admin? && !record.final?
  def export_pdf? = same_tenant?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(assessment: :patient).where(patients: { tenant_id: user.tenant_id })
    end
  end

  private

  def same_tenant?
    record.assessment.patient.tenant_id == user.tenant_id
  end

  def professional_or_above?
    same_tenant? && (user.saas_admin? || user.tenant_admin? || user.professional?)
  end

  def owner_or_admin?
    same_tenant? && (user.saas_admin? || user.tenant_admin? || record.created_by_id == user.id)
  end
end
