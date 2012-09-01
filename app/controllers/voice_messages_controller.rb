class VoiceMessagesController < ApplicationController
 # this is the handler for the initial phone call call and should correspond to the endpoint
 # configured in the Twilio dashboard for the app
  def incoming
    record_length = 360
    phone_number = params[:Caller]
    if User.users_available_for_conference.present?
      url_host = Rails.env == "development" ? "http://4xzb.localtunnel.com" : "http://#{request.host}"
      @user = User.find_or_create_by_phone_number(phone_number)
      incoming_call = PhoneCall.create(:call_type => "incoming", :user => @user, :callSID => params[:CallSID])
        
      conference = Conference.create(:user_incoming => @user.id)
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Hi, welcome to Vote Simple. Please hold while we try to connect you with a volunteer.'
        r.Dial(:StatusCallbackMethod => "GET", :StatusCallback => "#{url_host}/phone_calls/#{incoming_call.id}/response") do |d|
          d.Conference conference.id
        end
      end
      
      @client = Twilio::REST::Client.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])
      outgoing_call = PhoneCall.create(:call_type => "outgoing", :user => User.users_available_for_conference.first)
      
      # This is creating a new conference, not adding them to the existing conference
      # Probably need to use conference.sid to add to existing
      @client.account.calls.create({:record => true, :from => APP_CONFIG[:TWILIO_CALLER_ID], 
        :to => User.users_available_for_conference.first.phone_number, 
        :url => "#{url_host}/conferences/#{conference.id}.xml",
        :Timeout => "15", #seconds before trying someone else
        :IfMachine => "Hangup",
        :StatusCallbackMethod => "GET",
        :StatusCallback => "#{url_host}/phone_calls/#{outgoing_call.id}/response"})
      
      #if conference does not have 2 participants, then we didn't connect them, so VM
      # conference might temporarily have 2 people, so check the phone_call records of each to ensure active
      
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Hi, welcome to Vote Simple. For help voting in Wisconsin, please leave your question and a volunteer will call you back shortly."', :voice => 'woman'
        r.Record :action => voice_messages_recording_url, :maxLength => record_length
      end
      
    end

    render :xml => response.text

    # do you want to log the fact that you’re doing this step?
    # logging.info(FIXME - report that the caller called)
  end

 def recording
   phone_number = params[:Caller]
   
   # TODO Fix user and voter find by number
   @user = User.find_or_create_by_phone_number(phone_number)
   
   @user.phone_calls.create(:status => "left_message", :callSID => params[:CallSid], :recording_url => params[:RecordingUrl], :call_type => "incoming")
   
   head 200

 end
end