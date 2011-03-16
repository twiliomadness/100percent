require 'test_helper'

class SmsMessagesControllerTest < ActionController::TestCase
  test "should get incoming" do
    get :incoming
    assert_response :success
  end

end
