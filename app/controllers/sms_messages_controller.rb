class SmsMessagesController < ApplicationController

  before_filter :validate_request

  def incoming
    incoming_text = params[:Body]
    phone_number = params[:From]
    sms_city = params[:FromCity]
    sms_state = params[:FromState]
    sms_zip = params[:FromZip]
    twilio_number_used = params[:To]

    @user = User.find_or_create_by_phone_number(phone_number)
    @user.voter.update_attribute(:twilio_number_used, twilio_number_used) if @user.voter.present?
    @sms_voter = @user.voter.nil? ? @user.create_voter(:phone_number => phone_number, :twilio_number_used => twilio_number_used, :sms_city => sms_city, :sms_state => sms_state, :sms_zip => sms_zip) : @user.voter
    
    if @user.volunteer && ["on", "off"].include?(incoming_text.downcase)
      outgoing_text = @user.set_volunteer_status(incoming_text)
    else
      "Hello, for information on voting, please visit http://VoteSimple.org or call this number."
    end

    @voter.outgoing_messages.create(:text => outgoing_text) if outgoing_text.present?

    head 200
  end

private

  def validate_request
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    if Rails.env != "development" && !TwilioHelper.validateRequest(signature, request.url, request.post? ? params : {})
      Exceptional.context(:environment => Rails.env)
      raise "Invalid request with signature '#{signature}' for url '#{request.url}' with params: #{params}"
    end
  end

end
