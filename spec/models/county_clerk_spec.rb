require 'spec_helper'

describe CountyClerk do
  describe "#self.get_clerk" do
    it "should find UPPERCASE county" do
      filename = File.join(File.dirname(__FILE__), "address_information.html")
      content = File.new(filename).read()
      result = CountyClerk.get_county_name_from_html(content)
      expected = "Dane"
      
      result.should == expected
    end
    it "should find Title Case county" do
      filename = File.join(File.dirname(__FILE__), "address_information_2.html")
      content = File.new(filename).read()
      result = CountyClerk.get_county_name_from_html(content)
      expected = "Outagamie"
      
      result.should == expected
    end
  end
end
