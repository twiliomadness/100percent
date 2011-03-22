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

end
