class CountyClerk < ActiveRecord::Base
  has_many :voters

  validates_presence_of :county
  validates_presence_of :city
  
  scope :alphabetical_order, :order => "county"

  # TODO: have VoterRecord get the HTML for the voter, then PolingPlace and CountyClerk can go from there?

  def self.get_county_clerk(mechanize_page)
    county_name = get_county_name_from_html(mechanize_page.content)

    CountyClerk.find_by_county(county_name)
  end

  def self.get_county_name_from_html(page_html)
    pattern = /[\>\-]\s*([a-z ]+[a-z]) County/i
    match = pattern.match(page_html)
    match[1]
  end

  def sms_description
    # Update this if we end up splitting location_name and address
    "#{self.address}, #{self.city}".titleize
  end

end
