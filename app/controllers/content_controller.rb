class ContentController < ApplicationController
  before_filter :authenticate_user!, :except => :index

  def index
    if user_signed_in?
      redirect_to namedob_path and return
    end
  end

  def namedob
    @user = current_user
    @voter = @user.voters.new
  end

end
