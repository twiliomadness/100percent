class TextMessage < ActiveRecord::Base
  belongs_to :user
  
  scope :most_recent_first, :order => "created_at DESC"
end
