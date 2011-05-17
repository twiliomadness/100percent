class WebVotersController < ApplicationController

  before_filter :require_new_user, :only => :create

  def new
    @voter = WebVoter.new
  end

  def create
    @voter = WebVoter.new(params[:web_voter])
    respond_to do |format|
      if @voter.save
        sign_in(@voter.user)
        format.html { redirect_to dashboard_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    @voter = Voter.find(params[:id])
    respond_to do |format|
      if @voter.save
        flash[:notice] = 'Voter updated.'
        format.html { redirect_to update_voter_info_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voter.errors, :status => :unprocessable_entity }
      end
    end

  end

private

  def require_new_user
    if params[:web_voter][:user_attributes][:email].present? && User.find_by_email(params[:web_voter][:user_attributes][:email])
      flash[:notice] = "You already have an account with the email address #{params[:web_voter][:user_attributes][:email]}, please sign in."
      redirect_to new_user_session_path(:email => params[:web_voter][:user_attributes][:email])
    end
  end

end
