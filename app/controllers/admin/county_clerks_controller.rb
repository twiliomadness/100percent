class Admin::CountyClerksController < ApplicationController
  layout 'admin'

  expose(:county_clerk) { @county_clerk || CountyClerk.find_by_id(params[:county_clerk_id] || params[:id]) || CountyClerk.new }
  expose(:county_clerks) { CountyClerk.alphabetical_order }
end
