class SmsMessagesController < ApplicationController
  def incoming
    signature = request.headers['HTTP_X_TWILIO_SIGNATURE']
    if !TwilioHelper.validateRequest(signature, url, params)
      logger.error("Invalid request with signature #{signature} for url #{url} with params #{params}")
      # TODO: Return 500 error code and halt processing.
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

    @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
    @sms_voter = @user.sms_voter.nil? ? @user.create_sms_voter(:phone_number => phone_number) : @user.sms_voter

    outgoing_text = @sms_voter.process_message(incoming_text)

    if outgoing_text.kind_of?(Array)
      outgoing_text.each do |message|
        send_text(params[:From], message)
        @sms_voter.outgoing_messages.create(:text => message)
      end
    else
      send_text(params[:From], outgoing_text)
      @sms_voter.outgoing_messages.create(:text => outgoing_text)
    end

    head 200
  end

  def send_text(to, content)
    twilio = Twilio::RestAccount.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])

    if content.blank?
      logger.error
      raise "empty content to #{to}"
    end
    
    if content.size > 160
      logger.error
      raise "content is too long: #{content}"
    end

    data = {
      'From' => APP_CONFIG[:TWILIO_CALLER_ID],
      'To' => to,
      'Body' => content
    }

    path = "/2010-04-01/Accounts/#{APP_CONFIG[:TWILIO_ACCOUNT_SID]}/SMS/Messages"
    twilio_response = twilio.request(path, 'POST', data)

    logger.info("Sent #{data} to #{path} and got response code: #{twilio_response.code} and response body: #{twilio_response.body}")

    twilio_response.error! unless twilio_response.kind_of? Net::HTTPSuccess
  end
end
