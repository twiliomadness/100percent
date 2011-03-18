require 'spec_helper'

describe Voter do

  describe "#find_by_name_and_date_of_birth" do

    it "returns a Voter object when the voter is found" do
      result = Voter.find_by_name_and_date_of_birth('Mark', 'McEahern', TextParser.parse_date('7/4/1969'))
      expected = Voter.new(:address_line_1 => '2829 OAKRIDGE AVE', :city => 'MADISON', :zip => '53704')
      result.address_line_1.should == expected.address_line_1
      result.address_line_2.should == expected.address_line_2
      result.city.should == expected.city
      result.zip.should == expected.zip
    end

    it "returns nil when voter is not found" do
      result = Voter.find_by_name_and_date_of_birth('Mark', 'McEahern', TextParser.parse_date('7/4/1968'))
      result.should be_nil
    end
    
  end

end
