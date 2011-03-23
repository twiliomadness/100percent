require 'spec_helper'

describe CountyClerk do
  describe "#self.get_clerk" do
    it "should blah blah" do
      filename = File.join(File.dirname(__FILE__), "clerk_information.html")
      content = File.new(filename).read()
      result = CountyClerk.create_from_html(Nokogiri.HTML(content), "Dane")
      expected = CountyClerk.new(:location_name => 'CITY-COUNTY BLDG RM 106A  210 MARTIN LUTHER KING JR BLVD', :city => 'MADISON', :zip => '53703')
      
      result.location_name.should == expected.location_name
      result.city.should == expected.city
      result.zip.should == expected.zip
    end
  end
end
