class Admin::TextMessagesController < AdminController
  layout 'admin'

  expose(:messages) { Message.most_recent_first.paginate(:per_page => 50, :page => params[:page]) }

end
