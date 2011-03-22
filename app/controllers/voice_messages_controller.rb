class VoiceMessagesController < ApplicationController
 # this is the handler for the initial phone call call and should correspond to the endpoint
 # configured in the Twilio dashboard for the app
 def incoming
   # TODO: Validate that this is actually from twilio.
   # TODO: help, quit, reset, back, other verbs?

   # Limit the lenght of recordings
   record_length = 360  # six minutes
   phone_number = params[:Caller]

   # TODO: Needs update after Devise implementation.
   # Need to create both user and voter
   
   @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
   
   @response = Twilio::Response.new
   @response.append(Twilio::Say.new("Hi, welcome to Vote Simple.  For help in voting and registering to vote, please leave your first and last name.", :voice => "woman", :loop => "1"))
   @response.append(Twilio::Record.new(voice_messages_recording_url, :maxLength => record_length))

   render :xml => @response.respond

   # do you want to log the fact that you’re doing this step?
   # logging.info(FIXME - report that the caller called)
 end

 def recording(to, content)
   phone_number = params[:Caller]
   @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
   recording_URL = params[:RecordingUrl]
   
   voter = @user.voters.find_by_phone_number(phone_number)
   voter.update_attribute(:voice_recording_url, recording_URL)
   
   #update the user/voter with this recording
   # logging.info(FIXME - report that we have this caller’s recording)

   @response = Twilio::Response.new
   @response.append(Twilio::Say.new("Thank you! Someone will call back to assist you", :voice => "woman", :loop => "1"))
   @response.append(Twilio::Hangup.new())
   
   render :xml => @r.respond

 end
end