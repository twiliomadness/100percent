require 'spec_helper'

describe VoterRecord do

  describe "#find_by_name_and_date_of_birth" do

    it "returns a Voter object when the voter is found" do
      result = VoterRecord.find_by_name_and_date_of_birth('Scott', 'Walker', TextParser.parse_date('11/2/1967'))
      expected = VoterRecord.new(:address_line_1 => '520 N 68TH ST', :city => 'WAUWATOSA', :zip => '53213')
      result.address_line_1.should == expected.address_line_1
      result.address_line_2.should == expected.address_line_2
      result.city.should == expected.city
      result.zip.should == expected.zip
    end

    it "returns nil when voter is not found" do
      result = VoterRecord.find_by_name_and_date_of_birth('Mark', 'McEahern', TextParser.parse_date('7/4/1968'))
      result.should be_nil
    end
    
  end

end
