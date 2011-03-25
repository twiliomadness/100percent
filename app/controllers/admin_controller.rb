class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :ensure_admin
  
protected

  def ensure_admin
    if current_user.admin?
      
    else
      flash[:notice] = "You don't have rights to admin."
      redirect_to root_path
    end
  end
end
