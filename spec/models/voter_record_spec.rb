require 'spec_helper'

describe VoterRecord do

  describe "#find_by_name_and_date_of_birth" do

    it "returns a Voter object when the voter is found" do
      result = VoterRecord.find_by_name_and_date_of_birth('Scott', 'Walker', TextParser.parse_date('11/2/1967'))
      expected = VoterRecord.new(:address_line_1 => '520 N 68TH ST', :city => 'WAUWATOSA', :zip => '53213',:registration_date => "1/1/1918", :registration_status => "Active")
      result.address_line_1.should == expected.address_line_1
      result.address_line_2.should == expected.address_line_2
      result.city.should == expected.city
      result.zip.should == expected.zip
      result.registration_status.should == expected.registration_status
      result.registration_date.should == expected.registration_date
    end

    it "returns nil when voter is not found" do
      result = VoterRecord.find_by_name_and_date_of_birth('Scott', 'Walker', TextParser.parse_date('11/2/1968'))
      result.should be_nil
    end
    
  end

  describe "#get_address_link fo bof" do
    it "should get the correct link" do
      filename = File.join(File.dirname(__FILE__), "multiple_addresses_both.html")
      content = File.new(filename).read()
      link = VoterRecord.get_address_link("12 N. Butler", content)
      expected = "N BUTLER ST"
      
      link.text.should == expected
    end
  end

  describe "#get_address_link fo odd even" do
    it "should get the correct link" do
      filename = File.join(File.dirname(__FILE__), "multiple_addresses_odd_even.html")
      content = File.new(filename).read()
      link = VoterRecord.get_address_link("2915 Stowell Ave", content)
      expected = "AddressDetailsScreen.aspx?Language=en-us&AddressRangeID=24032440&DistrictComboID=100006468&JurisdictionID=1119"
      
      link.get_attribute("href").should == expected
    end
  end

  describe "#get_address_link fo odd even" do
    it "should get the correct link" do
      filename = File.join(File.dirname(__FILE__), "single_address.html")
      content = File.new(filename).read()
      link = VoterRecord.get_address_link("1909 Madison St", content)
      expected = "MADISON ST"
      
      link.text.should == expected
    end
  end
end
