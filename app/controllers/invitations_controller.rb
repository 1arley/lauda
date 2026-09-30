class InvitationsController < ApplicationController
  # Aceitar o convite acontece antes de existir sessão: o token do e-mail é a
  # prova de identidade, não um usuário logado. `verify_authorized` roda como
  # after_action e é satisfeito com `skip_authorization` em cada ação.
  skip_before_action :authenticate_user!, only: %i[accept accept_registration]

  before_action :set_invitation, only: %i[accept accept_registration]

  def new
    @invitation = current_user.tenant.invitations.build(role: :professional)
    authorize @invitation
  end

  def create
    @invitation = current_user.tenant.invitations.build(invitation_params)
    @invitation.invited_by = current_user
    authorize @invitation

    if @invitation.save
      InvitationMailer.with(invitation: @invitation, token: @invitation.raw_token).invite.deliver_later
      redirect_to new_invitation_path, notice: "Convite enviado para #{@invitation.email}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def accept
    skip_authorization
    @user = User.new
  end

  def accept_registration
    skip_authorization
    @user = @invitation.accept!(registration_params)

    sign_in(@user)
    redirect_to root_path, notice: 'Conta criada. Bem-vindo ao Lauda.'
  rescue ActiveRecord::RecordInvalid
    @user = User.new(registration_params.except(:password_confirmation))
    render :accept, status: :unprocessable_content
  end

  private

  def set_invitation
    @invitation = Invitation.find_valid(params[:token])
    return if @invitation

    redirect_to new_user_session_path, alert: 'Este convite é inválido ou já expirou.'
  end

  def invitation_params
    params.expect(invitation: %i[email role])
  end

  def registration_params
    params.expect(registration: %i[name password password_confirmation])
  end
end
