class UserMailer < ApplicationMailer
	default from: "email@changethis.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_changed.subject
  #
  @app_name = "School Business"

  def password_changed(id)
  	@user = User.find(id)

    mail to: @user.email, subject: "School Business: Your Password Has Changed"
  end

  def send_message(send_id, recip_id, email_body)
    @sender = User.find(send_id)
    @recipient = User.find(recip_id)
    @message = email_body
    mail(to: @recipient.email, 
          content_type: "text/html",
          subject: "School Business: #{@sender.name} has sent you a message.")
  end

  def event_claim(claim_id, owner_id, event_id)
    @claimer = User.find(claim_id)
    @owner = User.find(owner_id)
    @event = Event.find(event_id)
    mail to: @owner.email, subject: "School Business: #{@claimer.name} has claimed your event."
  end

  def confirm_speaker(owner_id, speaker_id, event_id)
    @speaker = User.find(speaker_id)
    @owner = User.find(owner_id)
    @event = Event.find(event_id)
    mail to: @speaker.email, subject: "School Business: #{@owner.name} has confirmed you as the speaker for an event."
  end

end