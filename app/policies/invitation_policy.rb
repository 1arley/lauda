class InvitationPolicy < ApplicationPolicy
  def new? = tenant_admin_above?
  def create? = tenant_admin_above?
  def accept? = false
  def accept_registration? = false

  private

  def tenant_admin_above?
    user.saas_admin? || user.tenant_admin?
  end
end
