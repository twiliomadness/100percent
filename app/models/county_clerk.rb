class CountyClerk < ActiveRecord::Base
  has_many :voters

  validates_presence_of :county
  validates_presence_of :city
  
  scope :alphabetical_order, :order => "county"

  # TODO: have VoterRecord get the HTML for the voter, then PolingPlace and CountyClerk can go from there?

  def self.get_county_clerk(mechanize_page)
    # get html for the clerk details then

    address_info_html = Nokogiri.HTML(mechanize_page.content)

    county_clerk_td_font_tag = address_info_html.xpath("//td/font[contains(text(), 'COUNTY CLERK')]")
    
    if county_clerk_td_font_tag.nil?
      #xpath 1.0 does not have upper case.  Gotta find a better way
      county_clerk_td_font_tag = address_info_html.xpath("//td/font[contains(text(), 'County Clerk')]")
    end
    
    county_name = county_clerk_td_font_tag.first.parent.parent.search("td/font")[2].inner_text.gsub(" County", "")
    
    CountyClerk.find_by_county(county_name)
  end

  def self.create_from_html(page_html, county)

    location_name_address = page_html.xpath("//input[@id = 'txtAddress1']").first.get_attribute("value")
    city_state_zip = page_html.xpath("//input[@id = 'txtAddress2']").first.get_attribute("value")
    phone_number = page_html.xpath("//input[@id = 'txtPhoneNumber']").first.get_attribute("value")
    clerk_email = page_html.xpath("//input[@id = 'txtEMailAddress']").first.get_attribute("value")

    county_clerk = CountyClerk.new
    county_clerk.county = county
    county_clerk.location_name = location_name_address.strip
    county_clerk.address = ""
    city, state_zip = city_state_zip.split(',')
    county_clerk.city = city
    county_clerk.zip = state_zip.split()[state_zip.split().size - 1]
    county_clerk.phone_number = phone_number
    county_clerk.email_address = clerk_email
    county_clerk.save!

    county_clerk

  end

  def sms_description
    # Update this if we end up splitting location_name and address
    "#{self.address}, #{self.city}".titleize
  end

end
