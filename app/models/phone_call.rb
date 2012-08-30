class PhoneCall < ActiveRecord::Base
  belongs_to :user
  
 #state_machine :status, :initial => :new do
 #  event :find_volunteer do
 #    transition any => :finding_volunteer
 #  end
 #
 #  state :needs_help
 #end
end
