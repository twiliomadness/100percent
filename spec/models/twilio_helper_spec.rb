require 'spec_helper'

describe TwilioHelper do
  describe "#self.validateRequest" do
    it "should return false when the signature is not valid" do
      signature = nil
      url = "junk"
      params = {}
      result = TwilioHelper.validateRequest(signature, url, params)
      result.should be_false
    end
  end
end
