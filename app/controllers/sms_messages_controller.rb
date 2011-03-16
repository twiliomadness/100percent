class SmsMessagesController < ApplicationController
  def incoming
    text = params['Body']
    phone_number = params['From']
    @user = User.find_or_create_by_phone_number(:phone_number => phone_number)
  end

end
