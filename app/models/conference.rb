class Conference < ActiveRecord::Base
  def twilio_conference
    @auth = {:username => APP_CONFIG[:TWILIO_ACCOUNT_SID], :password => APP_CONFIG[:TWILIO_ACCOUNT_TOKEN]}
    options = {:basic_auth => @auth }
    HTTParty.get("https://api.twilio.com/2010-04-01/Accounts/#{APP_CONFIG[:TWILIO_ACCOUNT_SID]}/Conferences", options)
  end
  
  
end
