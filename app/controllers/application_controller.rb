class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  before_action :set_current_attributes
  before_action :set_tenant

  after_action :verify_authorized, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, if: :pundit_policy_scoped?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def pundit_policy_scoped?
    !devise_controller? && respond_to?(:policy_scoped?, true)
  end

  def set_current_attributes
    return unless user_signed_in?

    Current.user_id = current_user.id
    Current.tenant_id = current_user.tenant_id
    Current.ip_address = request.remote_ip
  end

  def set_tenant
    return unless user_signed_in?

    ActsAsTenant.current_tenant = current_user.tenant
  end

  def user_not_authorized
    flash[:alert] = 'Você não tem permissão para esta ação.'
    redirect_back_or_to(root_path)
  end

  def record_not_found
    flash[:alert] = 'Registro não encontrado.'
    redirect_back_or_to(root_path)
  end
end
