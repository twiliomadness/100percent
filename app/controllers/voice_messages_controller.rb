class VoiceMessagesController < ApplicationController
 # this is the handler for the initial phone call call and should correspond to the endpoint
 # configured in the Twilio dashboard for the app
 def incoming
   # TODO: Validate that this is actually from twilio.
   # TODO: help, quit, reset, back, other verbs?

   # Limit the lenght of recordings
   record_length = 360  # six minutes
   phone_number = params[:Caller]

   @response = Twilio::Response.new
   @response.append(Twilio::Say.new("Hi, welcome to Vote Simple.  For help in voting and registering to vote, please leave your first and last name and someone will get back with you shortly.", :voice => "woman", :loop => "1"))
   @response.append(Twilio::Record.new(:action => voice_messages_recording_url, :maxLength => record_length))

   render :xml => @response.respond

   # do you want to log the fact that you’re doing this step?
   # logging.info(FIXME - report that the caller called)
 end

 def recording
   phone_number = params[:Caller]
   
   # TODO Fix user and voter find by number
   @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
   @voter = @user.voters.empty? ? @user.voters.create(:phone_number => phone_number, :type => "") : @user.voters.first
   
   recording_URL = params[:RecordingUrl]
   
   @voter.update_attribute(:voice_recording_url, recording_URL) 
   
   head 200

 end
end