class PhoneCallsController < ApplicationController
  def show
    # store this response
  end
  
  def twilio_response
    #if AnsweredBy=machine, then the call didn't go through
    @phone_call = PhoneCall.find(params[:id])
    @phone_call.update_attribute(:callSID, params[:CallSid])
    @phone_call.update_attribute(:answered_by, params[:AnsweredBy])
    
    head 200
  end
  
end
