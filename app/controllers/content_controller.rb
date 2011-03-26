class ContentController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :about]

  def index
    if user_signed_in? && !current_user.admin?
      redirect_to namedob_path and return
    end
  end

  def namedob
    @user = current_user
    @voter = @user.voters.empty? ? @user.voters.create : @user.voters.last
  end

  def about
  end

end

