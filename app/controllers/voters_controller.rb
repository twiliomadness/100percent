class VotersController < ApplicationController
  
  def new
    @voter = Voter.new
  end
  
  def create
    respond_to do |format|
      @voter = Voter.create(params[:voter])
      if @voter.save
        flash[:notice] = 'Voter updated.'
        format.html { redirect_to voter_path(@voter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @voter.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end

