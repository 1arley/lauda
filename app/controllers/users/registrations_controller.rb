module Users
  class RegistrationsController < Devise::RegistrationsController
    def create
      build_resource(sign_up_params)
      resource.role = :tenant_admin
      resource.tenant = Tenant.new(name: resource.tenant_name, subdomain: resource.subdomain)

      Tenant.transaction do
        resource.tenant.save!
        resource.save!
      end

      respond_to_sign_up
    rescue ActiveRecord::RecordInvalid
      copy_tenant_errors
      clean_up_passwords resource
      set_minimum_password_length
      render :new, status: :unprocessable_content
    end

    protected

    def respond_to_sign_up
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    end

    # Erros da clínica voltam para o formulário com o nome do campo de origem,
    # para que a mensagem não fique órfã em user[tenant_name].
    def copy_tenant_errors
      resource.tenant&.errors&.each do |error|
        resource.errors.add(error.attribute == :name ? :tenant_name : error.attribute, error.message)
      end
    end

    def sign_up_params
      configure_sign_up_params
      devise_parameter_sanitizer.sanitize(:sign_up)
    end

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: %i[name tenant_name subdomain])
    end
  end
end
