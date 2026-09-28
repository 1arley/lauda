module Users
  class SessionsController < Devise::SessionsController
    protected

    def after_sign_in_path_for(_resource)
      assessments_path
    end

    def after_sign_out_path_for(_resource_or_scope)
      new_user_session_path
    end
  end
end
