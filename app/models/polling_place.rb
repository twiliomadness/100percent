class PollingPlace < ActiveRecord::Base
  has_many :voters
  
  validates_presence_of :polling_place_id
  
  before_save :clean_polling_place_name
  
  # TODO: trim fields
  # http://www.mail-archive.com/rubyonrails-talk@googlegroups.com/msg22522.html
  
  def sms_description
    "#{self.location_name}, #{self.address}, #{self.city}"
  end
  
  def self.polling_place_id_from_link(polling_place_link)
    # Find this value:  PPLID=593214
    # https://vpa.wi.gov/PollingPlaceAccessibilityPage.aspx?Language=en-us&PPLID=593214&DistrictComboID=100012276&JurisdictionID=448
    rand(9999)
  end
  
  def clean_polling_place_name
    # 058-04 MUNICIPAL BUILDING
    # 35 - WIL-MAR NEIGHBORHOOD CENTER
  end
  
end
