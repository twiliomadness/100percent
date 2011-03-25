class Admin::VotersController < ApplicationController
  layout 'admin'

  expose(:voter) { @voter || Voter.find_by_id(params[:voter_id] || params[:id]) || Voter.new }
  expose(:voters) { Voter.all.paginate(:per_page => 50, :page => params[:page]) }
end
