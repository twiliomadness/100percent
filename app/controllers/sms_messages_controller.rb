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
    @user.sms_voter.update_attribute(:twilio_number_used, twilio_number_used) if @user.sms_voter.present?
    @sms_voter = @user.sms_voter.nil? ? @user.create_sms_voter(:phone_number => phone_number, :twilio_number_used => twilio_number, :sms_city => sms_city, :sms_state => sms_state, :sms_zip => sms_zip) : @user.sms_voter
    
    outgoing_text = @sms_voter.process_message(incoming_text)

    if outgoing_text.kind_of?(String)
      outgoing_text = [outgoing_text]
    end

    outgoing_text = outgoing_text.reject { |message| message.nil? || message.strip.blank? }

    outgoing_text.each do |message|
      m =  @sms_voter.outgoing_messages.create(:text => message)
      sleep 1 if outgoing_text.size > 1
    end

    head 200
  end

  private

    def validate_request
      signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
      if !TwilioHelper.validateRequest(signature, request.url, request.post? ? params : {})
        Exceptional.context(:environment => Rails.env)
        raise "Invalid request with signature '#{signature}' for url '#{request.url}' with params: #{params}"
      end
    end

end
