class CountyClerk < ActiveRecord::Base
  has_many :voters
  
  validates_presence_of :location_name
  validates_presence_of :city
  
  # TODO: have VoterRecord get the HTML for the voter, then PolingPlace and CountyClerk can go from there?
  
  def self.get_county_clerk(mechanize_page)
    # get html for the clerk details then
    
    address_info_html = Nokogiri.HTML(mechanize_page.content)
    
    county_clerk_td = address_info_html.xpath("//td[starts-with(text(), 'COUNTY CLERK')]")
    clerk_link = county_clerk_td.first.parent.search("td/a").first
    url = clerk_link.get_attribute("href")
    county_name = county_clerk_td.first.parent.search("td[ends-with(text(), 'County')]").first.gsub(" County", "")
    next_page = mechanize_page.link_with(:href => url).click
    county_clerk_html = Nokogiri.HTML(next_page.content)
    
    county_clerk = self.get_clerk_from_html(county_clerk_html, county_name)
  end
  
  def self.get_clerk_from_html(page_html, county)
    page_object = Nokogiri.HTML(page_html)
    
    location_name_address = page_object.xpath("//input[@id = 'txtAddress1']").first.get_attribute("value")
    city_state_zip = page_object.xpath("//input[@id = 'txtAddress2']").first.get_attribute("value")
    phone_number = page_object.xpath("//input[@id = 'txtPhoneNumber']").first.get_attribute("value")
    clerk_email = page_object.xpath("//input[@id = 'txtEMailAddress']").first.get_attribute("value")

    county_clerk = CountyClerk.find_by_county(county)
    
    # TODO: We're always updating PollingPlaces.  They sometimes change.
    if county_clerk.blank?
      county_clerk = CountyClerk.new
      county_clerk.location_name = location_name_address
      county_clerk.address = ""
      city, state_zip = city_state_zip.split(',')
      county_clerk.city = city
      county_clerk.zip = state_zip.split()[state_zip.split().size - 1]
      county_clerk.phone_number = phone_number
      county_clerk.email_address = clerk_email
      county_clerk.save
    end

    county_clerk
    
  end
  
  def sms_description
    # Update this if we end up splitting location_name and address
    "#{self.location_name}, #{self.city}".titleize
  end
  
end
