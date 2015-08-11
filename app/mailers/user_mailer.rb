class UserMailer < ApplicationMailer
	default from: "schoolbusinessapp@gmail.com"
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

  def welcome()
    mail to: current_user.email, subject: "Welcome to School Business!"
  end

  def test()
    mail to: "schoolbusinessapp@gmail.com", subject: "test"
  end

  def send_aws(email)
    ses = Aws::SES::Client.new(
      region: ENV["AWS_REGION"],
      credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY"], ENV["AWS_SECRET_KEY"])
      )
    response = ses.send_email({
      source: "schoolbusinessapp@gmail.com",
      destination: {
        to_addresses: ["d.cam09@gmail.com"],
        cc_addresses: [],
        bcc_addresses: [],
      },
      message: {
        subject: {
          data: "TestMessage",
          charset: "Charset",
        },
        body: {
          text: {
            data: "TestMessage", 
            charset: "Charset",
          },
          html: {
            data: "TestMessage", 
            charset: "Charset",
          },
        },
      },
      reply_to_addresses: ["schoolbusinessapp@gmail.com"],
    })
    puts response
  end

    def send_aws(email)
    ses = Aws::SES::Client.new(
      region: ENV["AWS_REGION"],
      credentials: mail_credentials
      )
    response = ses.send_email({
      source: "schoolbusinessapp@gmail.com",
      destination: {
        to_addresses: ["d.cam09@gmail.com"],
        cc_addresses: [],
        bcc_addresses: [],
      },
      message: {
        subject: {
          data: "TestMessage",
          charset: "Charset",
        },
        body: {
          text: {
            data: "TestMessage", 
            charset: "Charset",
          },
          html: {
            data: "TestMessage", 
            charset: "Charset",
          },
        },
      },
      reply_to_addresses: ["schoolbusinessapp@gmail.com"],
    })
    puts response
  end
end