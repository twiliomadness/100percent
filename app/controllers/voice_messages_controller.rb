class VoiceMessagesController < ApplicationController
 # this is the handler for the initial phone call call and should correspond to the endpoint
 # configured in the Twilio dashboard for the app
 def incoming
   # Limit the length of recordings
   record_length = 360  # six minutes
   phone_number = params[:Caller]

   @response = Twilio::Response.new
   @response.append(Twilio::Say.new("Hi, welcome to Vote Simple.  For help in voting and registering to vote, please leave name and we will call you back shortly.", :voice => "woman", :loop => "1"))
   @response.append(Twilio::Record.new(:action => voice_messages_recording_url, :maxLength => record_length))

   render :xml => @response.respond

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