require 'spec_helper'

describe PollingPlace do

  describe "#polling_place_id_from_link" do

    it "should return polling place ID" do
      url = "https://vpa.wi.gov/PollingPlaceAccessibilityPage.aspx?Language=en-us&PPLID=593214&DistrictComboID=100012276&JurisdictionID=448"
      expected = "593214"
      actual = PollingPlace.polling_place_id_from_link(url)
      actual.should == expected
    end

  end
  
  describe "#clean_location_name" do
    
    it "should remove non-alpha characters from the beginning" do
      value = "058-04 MUNICIPAL BUILDING"
      polling_place = PollingPlace.new(:location_name => value)
      expected = "MUNICIPAL BUILDING"
      polling_place.clean_location_name
      polling_place.location_name.should == expected
    end

  end
  
  describe "#clean_address" do
    
    it "should normalize whitespace" do
      value = " 101  MAIN   ST "
      polling_place = PollingPlace.new(:address => value)
      expected = "101 MAIN ST"
      polling_place.clean_address
      polling_place.address.should == expected
    end

  end

end
