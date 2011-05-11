class ContentController < ApplicationController

  def index
    if user_signed_in? && !current_user.admin?
      redirect_to dashboard_path and return
    end
  end

  def about
  end
  
  def donate
  end
  
  def contact
  end

end

