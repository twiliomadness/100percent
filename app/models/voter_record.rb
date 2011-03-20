class VoterRecord

  attr_accessor :address_line_1, :address_line_2, :city, :zip
  
  def initialize(attrs = {})
    self.address_line_1 = attrs[:address_line_1]
    self.address_line_2 = attrs[:address_line_2]
    self.city = attrs[:city]
    self.zip = attrs[:zip]
  end

  def self.default_attributes(attrs = {})
    {:address_line_1 => "123 MAIN ST.",
      :city => "MADISON",
      :zip => "53703"}.merge(attrs)
  end
    
  def self.lookup!(user)
    #TODO: this should decide to lookup user by name and dob or address based on user passed in
    # In general, I like to be explicit.  The caller should know what it is asking for
    # More than the provider deciding what the caller's gonna get
  end
  
  def self.find_address_record(address_line_1, city, zip)
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
      link_row_path = "//td[text() = '#{self.house_number_odd_even(user).capitalize!}']/.."
      link = link_row_path.search(path)
      logger.warn("Multiple address records for #{address_line_1} #{city} #{zip}")
      # If we don't have a link, something is really wrong.
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

    polling_place = PollingPlace.find_or_create_by_polling_place_id(polling_place_id)
    
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

  def self.find_by_name_and_date_of_birth(first_name, last_name, date_of_birth)
    # TODO: Record all searches, use as cache, etc.
    agent = Mechanize.new

    page = agent.get(APP_CONFIG[:VOTER_SEARCH_URL])

    form = page.form_with(:name => 'Form1')
    form.txtLastName = last_name
    form.txtFirstName = first_name
    form.txtDateOfBirth = date_of_birth.strftime("%m/%d/%Y")
    
    page = form.click_button
    
    result_page = Nokogiri.HTML(page.content)

    # Another approach is to look for links with href that contains VoterSummaryScreen in the link
    path = "//a[starts-with(@href, 'VoterSummaryScreen')]"

    links = result_page.xpath(path)
    if links.empty?
      return nil
    end

    # TODO: Handle possibility of more than one record
    if links.size > 1
      logger.warn("Found #{summary_links.size} for #{first_name} #{last_name} #{date_of_birth}")
    end

    link = links.first

    url = link.get_attribute("href")
    next_page = page.link_with(:href => url).click
    voter_info = Nokogiri.HTML(next_page.content)

    address_line_1 = voter_info.xpath("//input[@id = 'txtAddressLine1']").first.get_attribute("value")
    address_line_2 = voter_info.xpath("//input[@id = 'txtAddressline2']").first.get_attribute("value")
    city = voter_info.xpath("//input[@id = 'txtCity']").first.get_attribute("value")
    zip = voter_info.xpath("//input[@id = 'txtZipcode']").first.get_attribute("value")

    VoterRecord.new(:address_line_1 => address_line_1, :address_line_2 => address_line_2, :city => city, :zip => zip)

  end
  
  def self.house_number(address_line_1)
    # TODO: Make this smart
    if address_line_1.present?
      address_line_1.split(" ").first
    end
  end
  
  def self.street_name(address_line_1)
    address_line_1.gsub(house_number(address_line_1), "").strip
  end
  
  def self.house_number_odd_even(address_line_1)
    number = house_number(address_line_1)
    if number.to_i%2 == 0
      "even"
    else
      "odd"
    end
  end
end
