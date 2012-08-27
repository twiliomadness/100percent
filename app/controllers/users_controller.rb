class UsersController < ApplicationController
  def dashboard
    @voter = current_user.web_voter ||= current_user.create_web_voter
  end
  
  def volunteer_on
    current_user.set_on_call
    redirect_to dashboard_path
  end
  
  def volunteer_off
    current_user.set_to_not_on_call
    redirect_to dashboard_path
  end
end

