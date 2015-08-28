# In app/controllers/email_responses_controller.rb

require 'json'

class EmailResponsesController < ApplicationController

  #skip_authorization_check
  skip_before_filter :authenticate_user!
  skip_before_action :verify_authenticity_token

  before_action :log_incoming_message

  def bounce
    message = parseMessage
    return render json: {} unless isAuthentic(request.raw_post)

    if message["notificationType"] != 'Bounce'
      Rails.logger.info "Not a bounce - exiting"
      return render json: {}
    end

    bounce = message['bounce']
    if bounce["bounceType"] == "Transient"
      response_type = 'ooto'
    else
      response_type = 'bounce'
    end
    bouncerecps = bounce['bouncedRecipients']
    bouncerecps.each do |recp|
      email = recp['emailAddress']
      extra_info  = "status: #{recp['status']}, action: #{recp['action']}, diagnosticCode: #{recp['diagnosticCode']}"
      Rails.logger.info "Creating a bounce record for #{email}"

      EmailResponse.create ({ email: email, response_type: response_type, extra_info: extra_info})
      Notification.create(user_id: @event.user_id,
                              act_user_id: @claim.user_id
                              event_id: @event.id
                              n_type: :claim
                              read: false)
    end

    render json: {}
  end

  def complaint
    message = parseMessage
    return render json: {} unless isAuthentic(request.raw_post)

    if message["notificationType"] != 'Complaint'
      Rails.logger.info "Not a complaint - exiting"
      return render json: {}
    end

    complaint = message['complaint']
    recipients = complaint['complainedRecipients']
    recipients.each do |recp|
      email = recp['emailAddress']
      extra_info = "complaintFeedbackType: #{complaint['complaintFeedbackType']}"
      EmailResponse.create ( { email: email, response_type: 'complaint', extra_info: extra_info } )
    end

    render json: {}
  end

  protected

  def isAuthentic(message)
    verifier = Aws::SNS::MessageVerifier.new
    verifier.authentic?(message)
  end

  def log_incoming_message
    Rails.logger.info request.raw_post
  end

  def parseMessage
    @message ||= JSON.parse JSON.parse(request.raw_post)['Message']
  end
end