class TwilioHelper
  def self.validateRequest(signature, url, params)
    utils = Twilio::Utils.new(APP_CONFIG[:TWILIO_ACCOUNT_SID], APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])
    ignore = ['controller', 'action']
    filtered_params = params.reject { |k, v| ignore.includes?(k) }
    utils.validateRequest(signature, url, filtered_params)
  end
end
