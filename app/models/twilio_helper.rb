class TwilioHelper
  def self.validateRequest(signature, url, params)
    validator = Twilio::Util::RequestValidator.new(APP_CONFIG[:TWILIO_ACCOUNT_TOKEN])
    
    ignore = ['controller', 'action']
    filtered_params = params.reject { |k, v| ignore.include?(k) }
    
    validator.validate(url, filtered_params, signature)
  end
end
