class OutgoingMessage < TextMessage
  belongs_to :voter
  after_create :send_text
  validates_length_of :text, :maximum => 160, :minimum => 1

  def send_text
    # If a message is two returns, it is "valid", but we shouldn't send it.
    # TODO: We shouldn't send messages in cucumber tests.
    if text.strip.length > 0
      twilio = Twilio::RestAccount.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])

      data = {
        'From' => APP_CONFIG[:TWILIO_CALLER_ID],
        'To' => self.voter.phone_number,
        'Body' => text
      }

      path = "/2010-04-01/Accounts/#{APP_CONFIG[:TWILIO_ACCOUNT_SID]}/SMS/Messages"
      twilio_response = twilio.request(path, 'POST', data)
      twilio_response.error! unless twilio_response.kind_of? Net::HTTPSuccess
    end
  end

end
