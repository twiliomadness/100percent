class Admin::VotersController < ApplicationController
  layout 'admin'

  expose(:voter) { @voter || Voter.find_by_id(params[:voter_id] || params[:id]) || Voter.new }
  expose(:voters) { Voter.all.paginate(:per_page => 50, :page => params[:page]) }
  
  
  def update
    @voter = Voter.find_by_id(params[:id])
    
    respond_to do |format|
      if @voter.update_attributes(params[:sms_voter])
        flash[:notice] = 'Voter updated.'
        format.html { redirect_to admin_voters_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voter.errors, :status => :unprocessable_entity }
      end
    end
  end
end
