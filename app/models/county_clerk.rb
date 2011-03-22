class CountyClerk < ActiveRecord::Base
  has_many :voters
  
  validates_presence_of :location_name
  validates_presence_of :city
  
  before_save :clean_fields
  
  # TODO: have VoterRecord get the HTML for the voter, then PolingPlace and CountyClerk can go from there?
  
  def self.find_address_record(address_line_1, city, zip)
    # TODO: Rename this to find_polling_place.  yo.
    agent = Mechanize.new

    page = agent.get(APP_CONFIG[:ADDRESS_SEARCH_URL])

    form = page.form_with(:name => 'Form1')
    form.txtHouseNum = house_number(address_line_1)
    form.txtStreetName = street_name(address_line_1)
    form.txtCity = city
    form.txtZipcode = zip
    
    page = form.click_button
    
    result_page = Nokogiri.HTML(page.content)
    
    # Another approach is to look for links with href that contains VoterSummaryScreen in the link
    path = "//a[starts-with(@href, 'AddressDetailsScreen')]"

    links = result_page.xpath(path)
    
    # If street is on border of district, two rows returned - Odd side and Even side
    if links.size > 1
      # Grab the <td> with Odd as content
      link_row_path = "//td[text() = '#{self.house_number_odd_even(address_line_1).capitalize!}']"
      td = result_page.xpath(link_row_path)
      # the link is within the parent (the <tr>) of the selected <td>  like this:  <table><tr><td>Odd</td><td><a href="AddressDetailsScreen..."
      link = td.first.parent.search("td/a").first
    else
      link = links.first
    end
    
    if links.empty?
      return nil
    end
    
    url = link.get_attribute("href")
    next_page = page.link_with(:href => url).click
    address_info = Nokogiri.HTML(next_page.content)

    polling_place_name = address_info.xpath("//input[@id = 'PollingPlaceSummarySection1_txtName']").first.get_attribute("value")
    polling_place_address_line_a = address_info.xpath("//input[@id = 'PollingPlaceSummarySection1_txtAddressLineA']").first.get_attribute("value")
    poling_place_city = address_info.xpath("//input[@id = 'PollingPlaceSummarySection1_txtAddressLineB']").first.get_attribute("value")
    polling_place_zip = address_info.xpath("//input[@id = 'PollingPlaceSummarySection1_txtAddressLineC']").first.get_attribute("value")
    polling_place_hours = address_info.xpath("//input[@id = 'PollingPlaceSummarySection1_txtHours']").first.get_attribute("value")
    
    polling_place_link = address_info.xpath("//a[starts-with(@href, 'PollingPlaceAccessibilityPage')]").first.get_attribute("href")
    polling_place_id = PollingPlace.polling_place_id_from_link(polling_place_link)

    polling_place = PollingPlace.find_by_polling_place_id(polling_place_id)
    
    # TODO: We're always updating PollingPlaces.  They sometimes change.
    if polling_place.blank?
      polling_place = PollingPlace.new
      polling_place.location_name = polling_place_name
      polling_place.address = polling_place_address_line_a
      polling_place.city = poling_place_city
      polling_place.zip = polling_place_zip
      polling_place.hours = polling_place_hours
      polling_place.polling_place_id = polling_place_id
      polling_place.save
    end

    polling_place
    
  end
  
  def sms_description
    "#{self.location_name}, #{self.address}, #{self.city}".titleize
  end
  
  def clean_fields
    location_name_into_location_name_and_address
    split_city_state_zip
  end
  
  def location_name_into_location_name_and_address
    # CITY-COUNTY BLDG RM 106A  210 MARTIN LUTHER KING JR BLVD
    # This is what the strings look like.  Separate into location name:CITY-COUNTY BLDG RM 106A  and address:210 MARTIN LUTHER KING JR BLVD
    
    # For now, I'm storing this whole thing in the location_name field.
  end
  
  def split_city_state_zip
    # MADISON, WI 53703
    # Split this into city, state, zip
    
    # For now, I'm storing this whole thing in the city field.
  end
end
