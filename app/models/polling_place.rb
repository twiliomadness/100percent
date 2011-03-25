class PollingPlace < ActiveRecord::Base
  has_many :voters
  
  validates_presence_of :vpa_polling_place_id
  validates_presence_of :location_name
  validates_presence_of :address
  validates_presence_of :city
  validates_uniqueness_of :vpa_polling_place_id
  
  before_save :clean_fields
  
  # TODO: trim fields
  # http://www.mail-archive.com/rubyonrails-talk@googlegroups.com/msg22522.html
  
  def self.get_polling_place(address_details_page)
    # get html for the clerk details then
    
    address_info_html = Nokogiri.HTML(address_details_page.content)

    polling_place_name = address_info_html.xpath("//input[@id = 'PollingPlaceSummarySection1_txtName']").first.get_attribute("value")
    polling_place_address_line_a = address_info_html.xpath("//input[@id = 'PollingPlaceSummarySection1_txtAddressLineA']").first.get_attribute("value")
    polling_place_city = address_info_html.xpath("//input[@id = 'PollingPlaceSummarySection1_txtAddressLineB']").first.get_attribute("value")
    polling_place_zip = address_info_html.xpath("//input[@id = 'PollingPlaceSummarySection1_txtAddressLineC']").first.get_attribute("value")
    polling_place_hours = address_info_html.xpath("//input[@id = 'PollingPlaceSummarySection1_txtHours']").first.get_attribute("value")
    
    polling_place_link = address_info_html.xpath("//a[starts-with(@href, 'PollingPlaceAccessibilityPage')]").first.get_attribute("href")
    vpa_polling_place_id = PollingPlace.polling_place_id_from_link(polling_place_link)

    polling_place = PollingPlace.find_by_vpa_polling_place_id(vpa_polling_place_id)
    
    # TODO: We're always updating PollingPlaces.  They sometimes change.
    if polling_place.blank?
      polling_place = PollingPlace.new
      polling_place.location_name = polling_place_name
      polling_place.address = polling_place_address_line_a
      polling_place.city = polling_place_city
      polling_place.zip = polling_place_zip
      polling_place.hours = polling_place_hours
      polling_place.vpa_polling_place_id = vpa_polling_place_id
      polling_place.save!
    end

    polling_place
  end
  
  def self.create_from_html(page_html, county)
    page_object = Nokogiri.HTML(page_html)
    
    
  end
  
  def sms_description
    "#{self.location_name}, #{self.address}, #{self.city}".titleize
  end

  def self.polling_place_id_from_link(polling_place_link)
    uri = URI.parse(polling_place_link)
    params = Hash[URI.decode_www_form(uri.query)]
    params["PPLID"]
  end
  
  def clean_fields
    clean_location_name
    clean_address
  end
  
  def clean_location_name
    self.location_name = self.location_name.sub(/^[^a-z]*/i, '')
  end
  
  def clean_address
    self.address = TextParser.normalize_whitespace(self.address)
  end
  
end
