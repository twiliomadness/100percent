class SmsMessagesController < ApplicationController
  def incoming
    logger.info params
  end

end
