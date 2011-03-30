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
    
    address_info_html = Nokogiri.HTML(page_html)

    county_clerk_td_font_tag = address_info_html.xpath("//td[contains(text(), 'COUNTY CLERK')]")
    
    if county_clerk_td_font_tag.first.nil?
      #xpath 1.0 does not have upper case.  Gotta find a better way
      county_clerk_td_font_tag = address_info_html.xpath("//td[contains(text(), 'County Clerk')]")
    end
    
    county_name = county_clerk_td_font_tag.first.parent.search("td")[2].inner_text.gsub(" County", "")

  end

  def sms_description
    # Update this if we end up splitting location_name and address
    "#{self.address}, #{self.city}".titleize
  end

end
