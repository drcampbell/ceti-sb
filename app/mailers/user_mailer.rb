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
end
