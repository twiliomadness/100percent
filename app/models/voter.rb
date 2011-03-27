class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages, :conditions => {:type => 'IncomingMessage'} 
  has_many :outgoing_messages, :conditions => {:type => 'OutgoingMessage'} 
  belongs_to :polling_place
  belongs_to :county_clerk
  
  scope :most_recent_first, :order => "created_at DESC"

  def next_election_date
    # TODO: Implement election class which this will utilize
    "April 5th"
  end
  
  def is_registered?
    self.registration_status.present?  && self.registration_status.downcase == "active"
  end
  
  def update_voter_address
    address_details_page = VoterRecord.get_address_details_page(self.address_line_1, self.city, self.zip)
    
    success = true
    if address_details_page
      polling_place = PollingPlace.get_polling_place(address_details_page)
      if polling_place.nil?
        params = {:address_line_1 => self.address_line_1,
          :city => self.city,
          :zip => self.zip}
        Exceptional.handle(Exception.new, "Unable to find polling place for params: #{params}")
        success = false
      else
        self.update_attribute(:polling_place_id, polling_place.id)
      end

      county_clerk = CountyClerk.get_county_clerk(address_details_page)
      if county_clerk.nil?
        params = {:address_line_1 => self.address_line_1,
          :city => self.city,
          :zip => self.zip}
        Exceptional.handle(Exception.new, "Unable to find county clerk for params: #{params}")
        success = false
      else
        self.update_attribute(:county_clerk_id, county_clerk.id)
      end
    else  
      success = false
    end
    return success
  end
  
end
