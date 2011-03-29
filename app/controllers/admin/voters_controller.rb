class Admin::VotersController < AdminController
  layout 'admin'

  expose(:voter) { @voter || Voter.find_by_id(params[:voter_id] || params[:id]) || Voter.new }
  expose(:voters) { Voter.most_recent_first.paginate(:per_page => 50, :page => params[:page]) }

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
  
  def send_text_message
    @voter = Voter.find_by_id(params[:voter_id])
    
    message_text = params[:voter][:message_text]
    
    @voter.send_text_message_from_admin(message_text)
    
    redirect_to admin_voter_path(@voter)
    
  end
end
