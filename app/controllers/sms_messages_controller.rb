class SmsMessagesController < ApplicationController

  def incoming
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    if !TwilioHelper.validateRequest(signature, request.url, request.post? ? params : {})
      logger.error("Invalid request with signature #{signature} for url #{request.url} with params #{params}")
      head 404 and return
    end
    incoming_text = params[:Body]
    phone_number = params[:From]
    sms_city = params[:FromCity]
    sms_state = params[:FromState]
    sms_zip = params[:FromZip]

    @user = User.find_or_create_by_phone_number(phone_number)
    @sms_voter = @user.sms_voter.nil? ? @user.create_sms_voter(:phone_number => phone_number, :sms_city => sms_city, :sms_state => sms_state, :sms_zip => sms_zip) : @user.sms_voter

    outgoing_text = @sms_voter.process_message(incoming_text)

    if outgoing_text.kind_of?(String)
      outgoing_text = [outgoing_text]
    end

    outgoing_text.each do |message|
      @sms_voter.outgoing_messages.create(:text => message)
    end

    head 200
  end

end
