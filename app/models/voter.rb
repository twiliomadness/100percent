class Voter < ActiveRecord::Base
  belongs_to :user
  has_many :incoming_messages, :conditions => {:type => 'IncomingMessage'}
  has_many :outgoing_messages, :conditions => {:type => 'OutgoingMessage'}
  belongs_to :polling_place
  belongs_to :county_clerk
  has_many :text_messages
  
  validates :address_line_1, :presence => {:if => Proc.new {|v| v.type == 'WebVoter'}}
  validates :first_name, :presence => {:if => Proc.new {|v| v.type == 'WebVoter'}}
  validates :city, :presence => {:if => Proc.new {|v| v.type == 'WebVoter'}}

  before_validation do
    self.zip = self.zip[0..4] unless self.zip.nil?
  end

  scope :most_recent_first, :order => "created_at DESC"
  scope :need_help, :conditions => "help_status = 'pending_help_exit'"

  def assembly
    if assembly_district.present?
      Assembly.find_by_district_id(assembly_district)
    end
  end

  def senate
    if senate_district.present?
      Senate.find_by_district_id(senate_district)
    end
  end

  def send_text_message_from_admin(message_text)
    # In the future, we should keep track which volunteer sent this
    self.outgoing_messages.create(:text => message_text)
  end

  def friendly_election_day
    election_date = next_election_date
    month = election_date.strftime("%b").capitalize
    day = election_date.strftime("%d").to_i.ordinalize
    month + " " + day
  end

  def next_election_date
    elections = []
    if assembly && assembly.elections.pending.any?
      next_assembly_election = self.assembly.elections.pending.first
      elections << next_assembly_election
    end

    if senate && assembly.elections.pending.any?
      next_senate_election = self.senate.elections.pending.first
      elections << next_senate_election
    end

    if elections.any?
      elections.sort! { |a,b| a.date <=> b.date }.first.date
    else
      nil
    end

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
    # The name of this method probably needs updating.
    address_details_page = VoterRecord.get_address_details_page(self.address_line_1, self.city, self.zip)
    params = {:address_line_1 => self.address_line_1,
      :city => self.city,
      :zip => self.zip}
    success = true
    if address_details_page
      polling_place = PollingPlace.get_polling_place(address_details_page)
      if polling_place.nil?
        Exceptional.handle(Exception.new, "Unable to find polling place for params: #{params}")
      else
        self.update_attribute(:polling_place_id, polling_place.id)
      end

      county_clerk = CountyClerk.get_county_clerk(address_details_page)
      if county_clerk.nil?
        Exceptional.handle(Exception.new, "Unable to find county clerk for params: #{params}")
      else
        self.update_attribute(:county_clerk_id, county_clerk.id)
      end

      assembly_district = Voter.get_assembly_district_from_html(address_details_page.content)
      if assembly_district.nil?
        Exceptional.handle(Exception.new, "Unable to find assembly district for params: #{params}")
      else
        self.update_attribute(:assembly_district, assembly_district.to_i)
      end

      senate_district = Voter.get_senate_district_from_html(address_details_page.content)
      if senate_district.nil?
        Exceptional.handle(Exception.new, "Unable to find senate district for params: #{params}")
      else
        self.update_attribute(:senate_district, senate_district.to_i)
      end

    else
      Exceptional.handle(Exception.new, "Unable to find address page for params: #{params}")
      success = false
    end
    return success
  end

  def self.get_assembly_district_from_html(page_html)
    # ASSEMBLY - DISTRICT 67
    pattern = /ASSEMBLY\s+\-\s+DISTRICT\s+(\d+)/i
    match = pattern.match(page_html)
    match[1]
  end

  def self.get_senate_district_from_html(page_html)
    # STATE SENATE - DISTRICT 23
    pattern = /STATE SENATE\s+\-\s+DISTRICT\s+(\d+)/i
    match = pattern.match(page_html)
    match[1]
  end

  def lookup_address_via_geocode
    result = Geokit::Geocoders::GoogleGeocoder.geocode("#{self.address_line_1}, #{self.city}, WI")
  end
  
  def update_zip_from_geocode
    result = lookup_address_via_geocode
    if result.success && result.all.size == 1
      self.zip = result.zip
      self.save
    end
  end
  
  def update_voting_information
    if self.zip.blank?
      update_zip_from_geocode
    end
    if self.zip.present?
      self.update_voter_polling_place_clerk
    end
  end
  

end
