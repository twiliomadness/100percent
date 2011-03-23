class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages, :conditions => {:type => 'IncomingMessage'} 
  has_many :outgoing_messages, :conditions => {:type => 'OutgoingMessage'} 
  belongs_to :polling_place
  belongs_to :county_clerk

  # TODO: Add validation of address format here?
  # number and name are required.  Punctuation and apt/suite # s/b removed


  def update_voter_address
    address_details_page = VoterRecord.get_address_details_page(self.address_line_1, self.city, self.zip)
    
    success = true
    if address_details_page
      polling_place = PollingPlace.get_polling_place(address_details_page)
      if polling_place.nil?
        logger.error("Unable to find polling place for #{self.address_line_1} ...")
        success = false
      else
        self.update_attribute(:polling_place_id, polling_place.id)
      end

      county_clerk = CountyClerk.get_county_clerk(address_details_page)
      if county_clerk.nil?
        logger.error("Unable to find county clerk for #{self.address_line_1} ...")
        success = false
      else
        self.update_attribute(:county_clerk_id, county_clerk.id)
      end
    else  
      success = false
    end
    success
  end
end
