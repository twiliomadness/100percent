class Admin::TextMessagesController < ApplicationController
  layout 'admin'

  expose(:messages) { Message.most_recent_first.paginate(:per_page => 50, :page => params[:page]) }
end
