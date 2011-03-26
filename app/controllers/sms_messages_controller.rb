class SmsMessagesController < ApplicationController
  def incoming
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    if !TwilioHelper.validateRequest(signature, request.url, params)
      logger.error("Invalid request with signature #{signature} for url #{request.url} with params #{params}")
      head 404 and return
    end
    incoming_text = params[:Body]
    phone_number = params[:From]
    # TODO: Take this out once we're live.
    if incoming_text.strip.downcase == 'xxx'
      user = User.find_by_phone_number(phone_number)
      if user
        user.sms_voter.incoming_messages.destroy_all
        user.sms_voter.outgoing_messages.destroy_all
        user.destroy
      end
    end

    @user = User.find_or_create_by_phone_number(phone_number)
    @sms_voter = @user.sms_voter.nil? ? @user.create_sms_voter(:phone_number => phone_number) : @user.sms_voter

    outgoing_text = @sms_voter.process_message(incoming_text)

    if outgoing_text.kind_of?(String)
      outgoing_text = [outgoing_text]
    end

    outgoing_text.each do |message|
      m =  @sms_voter.outgoing_messages.create(:text => message)
    end

    head 200
  end

end
