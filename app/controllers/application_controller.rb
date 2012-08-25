class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(user)
    if user.admin
      admin_path
    else
      dashboard_path if !user.admin
    end
  end
end
