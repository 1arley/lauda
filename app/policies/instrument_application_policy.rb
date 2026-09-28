class InstrumentApplicationPolicy < ApplicationPolicy
  def index? = true
  def show? = same_tenant?
  def create? = professional_or_above?
  def edit_answers? = professional_or_above?
  def update_answers? = professional_or_above?
  def score? = professional_or_above?
  def compute? = professional_or_above?
  def results? = same_tenant?
  def destroy? = owner_or_admin?

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
    same_tenant? && (user.saas_admin? || user.tenant_admin? || record.applied_by_id == user.id)
  end
end
