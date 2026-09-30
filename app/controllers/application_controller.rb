class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Pundit::Authorization

  around_action :with_request_context
  before_action :authenticate_user!, unless: :devise_controller?

  after_action :verify_authorized, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, if: :pundit_policy_scoped?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def pundit_policy_scoped?
    !devise_controller? && respond_to?(:policy_scoped?, true)
  end

  def with_request_context(&)
    user = current_user

    Current.set(user_id: user&.id, tenant_id: user&.tenant_id, ip_address: request.remote_ip) do
      ActsAsTenant.with_tenant(user&.tenant, &)
    end
  end

  def user_not_authorized
    flash[:alert] = 'Você não tem permissão para esta ação.'
    redirect_back_or_to(root_path)
  end

  def record_not_found
    flash[:alert] = 'Registro não encontrado.'
    redirect_back_or_to(root_path)
  end

  def parameter_missing
    flash[:alert] = 'Requisição inválida: dados ausentes. Envie o formulário novamente.'
    redirect_back_or_to(root_path)
  end
end
