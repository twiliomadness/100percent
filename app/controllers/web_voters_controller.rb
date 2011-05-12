class WebVotersController < ApplicationController
  
  def new
    @user = User.create!
    sign_in(@user) if current_user.blank?
    @voter = WebVoter.new
  end
  
  def create
    respond_to do |format|
      @voter = WebVoter.create(params[:web_voter])
      if params[:email].present? 
        if User.find_by_email(params[:email]).present?
          flash[:notice] = "You already have an account, please sign in."
          sign_out(current_user)
          redirect_to new_user_session_path and return
        end
        current_user.update_attribute(:email, params[:email])
      else
        flash[:notice] = "Email address is required."
        render :action => "edit" and return
      end
      @voter.user_id = current_user.id
      if @voter.save
        format.html { redirect_to update_voter_info_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voter.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update_voting_info
    current_user.web_voter.update_voting_information
    redirect_to dashboard_path
  end
  
  def edit
    
  end
  
  def update
    @voter = Voter.find(params[:id])
    current_user.web_voter.update_voting_information
    respond_to do |format|
      if @voter.save
        flash[:notice] = 'Voter updated.'
        format.html { redirect_to dashboard_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voter.errors, :status => :unprocessable_entity }
      end
    end
    
  end
  
end

