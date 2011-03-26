class Admin::UsersController < AdminController
  layout 'admin'

  expose(:user) { @user || User.find_by_id(params[:user_id] || params[:id]) || User.new }
  expose(:users) { User.all.paginate(:per_page => 50, :page => params[:page]) }
end
