class DashboardController < ApplicationController

  def index
    @voter = current_user.web_voter
  end

end

