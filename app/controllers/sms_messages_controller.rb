class SmsMessagesController < ApplicationController
  def incoming
    # TODO: Validate that this is actually from twilio.
    incoming_text = params[:Body]
    phone_number = params[:From]
    @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
    # TODO: Save outgoing message too, inside process_message()?
    outgoing_text = @user.process_message(incoming_text)
    send_text(params[:From], outgoing_text)
    head 200
  end

  def send_text(to, content)
    twilio = Twilio::RestAccount.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])

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
