class Admin::CountyClerksController < AdminController
  layout 'admin'

  expose(:county_clerk) { @county_clerk || CountyClerk.find_by_id(params[:county_clerk_id] || params[:id]) || CountyClerk.new }
  expose(:county_clerks) { CountyClerk.all }
end
