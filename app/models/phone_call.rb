class PhoneCall < ActiveRecord::Base
  belongs_to :user
  
  state_machine :status, :initial => :new do
    event :find_volunteer do
      transition any => :finding_volunteer
    end

    state :new
    state :finding_volunteer
  end
  
  def find_volunteer
    # find one darnit
  end
end
