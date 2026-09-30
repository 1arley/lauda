class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @url = accept_invitation_url(token: params[:token])
    @tenant_name = @invitation.tenant.name

    mail to: @invitation.email, subject: "#{@tenant_name} convidou você para o Lauda"
  end
end
