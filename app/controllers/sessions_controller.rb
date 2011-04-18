class SessionsController < ApplicationController
  def create
    render :text => request.env["omniauth.auth"]
  end

  def fail
  end


end
