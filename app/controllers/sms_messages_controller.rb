class SmsMessagesController < ApplicationController
  def incoming
    incoming_text = params[:Body]
    phone_number = params[:From]
    @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
    @incoming_message = @user.incoming_messages.create!(:text => incoming_text)
    if @user.incoming_messages.size == 1
      outgoing_text = 'Welcome!'
    else
      outgoing_text = 'Hi again!'
    end
    send_text params[:From], outgoing_text
    head 200
  end

  def send_text(to, content)
      twilio = Twilio::RestAccount.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])

      d = {
        'From' => APP_CONFIG[:TWILIO_CALLER_ID],
        'To' => to,
        'Body' => content
      }

      path = "/2010-04-01/Accounts/#{APP_CONFIG[:TWILIO_ACCOUNT_SID]}/SMS/Messages"
      resp = twilio.request(path, 'POST', d)

      resp.error! unless resp.kind_of? Net::HTTPSuccess
      puts "code: %s\nbody: %s" % [resp.code, resp.body]

  end
end
