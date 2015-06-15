class UserMailer < ApplicationMailer
	default from: "email@changethis.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_changed.subject
  #
  def password_changed(id)
  	@user = User.find(id)

    mail to: @user.email, subject: "School Business: Your Password Has Changed"
  end

  def send_message(send_id, recip_id)
    @sender = User.find(send_id)
    @recip = User.find(recip_id)
    mail to: @recip.email, subject: "School Business: #{@sender.name} has sent you a message."
  end
end
