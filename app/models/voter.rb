class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages, :conditions => {:type => 'IncomingMessage'} 
  has_many :outgoing_messages, :conditions => {:type => 'OutgoingMessage'} 
  belongs_to :polling_place
  belongs_to :county_clerk
  has_many :text_messages
  
  before_validation do
   self.zip = self.zip[0..4] unless self.zip.nil?
  end
  
  scope :most_recent_first, :order => "created_at DESC"
  scope :need_help, :conditions => "help_status = 'pending_help_exit'"

  def send_text_message_from_admin(message_text)
    # In the future, we should keep track which volunteer sent this
    self.outgoing_messages.create(:text => message_text)
  end
  
  def next_election_date
    # TODO: Implement election class which this will utilize
    "April 5th"
  end
  
  def is_registered?
    self.registration_status.present?  && self.registration_status.downcase == "active"
  end

  def update_attributes_from_voter_record(voter_record)
    self.address_line_1 = voter_record.address_line_1
    self.address_line_2 = voter_record.address_line_2
    self.city = voter_record.city
    self.zip = voter_record.zip
    self.registration_date = voter_record.registration_date
    self.registration_status = voter_record.registration_status
  end
  
  def update_voter_polling_place_clerk
    address_details_page = VoterRecord.get_address_details_page(self.address_line_1, self.city, self.zip)
    params = {:address_line_1 => self.address_line_1,
      :city => self.city,
      :zip => self.zip}
    success = true
    if address_details_page
      polling_place = PollingPlace.get_polling_place(address_details_page)
      if polling_place.nil?
        Exceptional.handle(Exception.new, "Unable to find polling place for params: #{params}")
        success = false
      else
        self.update_attribute(:polling_place_id, polling_place.id)
      end

      county_clerk = CountyClerk.get_county_clerk(address_details_page)
      if county_clerk.nil?
        Exceptional.handle(Exception.new, "Unable to find county clerk for params: #{params}")
        success = false
      else
        self.update_attribute(:county_clerk_id, county_clerk.id)
      end
    else
      Exceptional.handle(Exception.new, "Unable to find address page for params: #{params}")
      success = false
    end
    return success
  end
  
end
