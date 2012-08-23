class VoiceMessagesController < ApplicationController
 # this is the handler for the initial phone call call and should correspond to the endpoint
 # configured in the Twilio dashboard for the app
  def incoming
    record_length = 360
    phone_number = params[:Caller]
    if User.users_available_for_conference.present?
      
      conference = Conference.create
      
      @client = Twilio::REST::Client.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])
      @client.account.calls.create({:from => APP_CONFIG[:TWILIO_CALLER_ID], :to => User.users_available_for_conference.first.phone_number, :url => "http://wigotv-staging.heroku.com/conferences/#{conference.id}"})
    
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Hi, welcome to Vote Simple. Please hold while we try to connect you with a volunteer.', :voice => 'woman'
        r.Dial do |d|
          d.Conference conference.id
        end
      end
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
   @voice_voter = @user.voice_voter.nil? ? @user.create_voice_voter(:phone_number => phone_number) : @user.voice_voter
   
   recording_URL = params[:RecordingUrl]
   
   @voice_voter.update_attribute(:voice_recording_url, recording_URL) 
   
   head 200

 end
end