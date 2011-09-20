class DashboardController < ApplicationController

  def index
    @voter = current_user.web_voter ||= current_user.create_web_voter
  end

end

