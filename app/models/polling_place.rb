class PollingPlace < ActiveRecord::Base
  has_many :voters
  
  validates_presence_of :polling_place_id
  validates_presence_of :location_name
  validates_presence_of :address
  validates_presence_of :city
  
  before_save :clean_fields
  
  # TODO: trim fields
  # http://www.mail-archive.com/rubyonrails-talk@googlegroups.com/msg22522.html
  
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
