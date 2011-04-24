require 'spec_helper'

describe Voter do
  describe "#self.get_assembly_district_from_html" do
    it "should find assembly district" do
      filename = File.join(File.dirname(__FILE__), "address_information.html")
      content = File.new(filename).read()
      result = Voter.get_assembly_district_from_html(content)
      expected = "78"
      
      result.should == expected
    end
  end
  describe "#self.get_senate_district_from_html" do
    it "should find senate district" do
      filename = File.join(File.dirname(__FILE__), "address_information.html")
      content = File.new(filename).read()
      result = Voter.get_senate_district_from_html(content)
      expected = "26"
      
      result.should == expected
    end
  end
end
