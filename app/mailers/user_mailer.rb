class UserMailer < ApplicationMailer
	default from: "support@school2biz.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_changed.subject
  #
  @app_name = "School Business"

  def password_changed(id)
  	@user = User.find(id)
    mail to: @user.email, subject: "School Business: Your Password Has Changed"
    #@message = "Hi #{@user.name}, <br>We wanted to let you know that your password was changed. If this was done without your knowledge, please contact us at support@school2biz.com.<br><br>Thanks!<br><br>School Business Team"
    #mail(to: @user.email, content_type: "text/html", subject: "School Business: Your Password Has Changed")
  	puts "\npassword change "
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

  def event_cancel(recip_id, send_id, event_id)
    @recipient = User.find(recip_id)
    @sender = User.find(send_id)
    @event = Event.find(event_id)
    mail to: @recipient.email, subject: "School Business: #{@sender.name} has canceled their event."
  end

  def confirm_speaker(owner_id, speaker_id, event_id)
    @speaker = User.find(speaker_id)
    @owner = User.find(owner_id)
    @event = Event.find(event_id)
    mail to: @speaker.email, subject: "School Business: #{@owner.name} has confirmed you as the speaker for an event."
  end

  def cancel_speaker(speaker_id, owner_id, event_id)
    @speaker = User.find(speaker_id)
    @owner = User.find(owner_id)
    @event = Event.find(event_id)
    mail to: @owner.email, subject: "School Business: #{@speaker.name} had to cancel their speaking engagement for your event."
  end

  def cancel_claim(claimer_id, owner_id, event_id)
    @claimer = User.find(claimer_id)
    @owner = User.find(owner_id)
    @event = Event.find(event_id)
    mail to: @owner.email, subject: "School Business: #{@claimer.name} has canceled their claim for your event."
  end

  def reject_claim(claimer_id, owner_id, event_id)
    @claimer = User.find(claimer_id)
    @owner = User.find(owner_id)
    @event = Event.find(event_id)
    mail to: @claimer.email, subject: "School Business: #{@owner.name} has chosen not to move forward with your claim."
  end

  def welcome(user_id)
    @id = user_id
    mail to: User.find(@id).email, subject: "Welcome to School Business!"
  end

  def bounce_test()
    mail to: "bounce@simulator.amazonses.com", subject: "bounce test"
  end

  def complaint_test()
    mail to: "complaint@simulator.amazonses.com", subject: "complaint test"
  end

  def ooto_test()
    mail to: "ooto@simulator.amazonses.com", subject: "ooto test"
  end

  def test()
    mail to: "success@simulator.amazonses.com", subject: "test"
  end

  def send_aws(email)
    ses = Aws::SES::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id: ENV["SENDGRID_USERNAME"], 
      secret_access_key: ENV["SENDGRID_PASSWORD"])
    begin
      response = ses.send_email(test_mail)
    rescue Aws::SES::Errors::ServiceError => error
      puts "Error"
      puts error.message

    end
    puts response
  end

  def test_mail()
    mail = {
      source: "support@school2biz.com",
      destination: {
        to_addresses: ["bounce@simulator.amazonses.com"],
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
      reply_to_addresses: ["support@school2biz.com"],
    }
  end

def test2()
    mail2 = {
      source: "support@school2biz.com",
      destination: {
        to_addresses: ["bounce@simulator.amazonses.com"],
        cc_addresses: [],
        bcc_addresses: [],
      },
      message: {
        subject: {
          data: "TestMessage",
        },
        body: {
          text: {
            data: "TestMessage", 
          },
          html: {
            data: "TestMessage", 
          },
        },
      },
   }
end

  def send_aws2(email)
    ses = Aws::SES::Client.new(
      region: ENV["AWS_REGION"],
      access_key_id:  ENV["SENDGRID_USERNAME"], 
      secret_access_key: ENV["SENDGRID_PASSWORD"])
    response = ses.send_email(test_mail)
    puts response
  end
end
