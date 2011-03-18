require 'spec_helper'

describe TextParser do

  describe "#parse_date" do

    it "returns a Time object for mm/dd/yyyy" do
      text = "7/4/1969"
      result = TextParser.parse_date(text)
      result.should == Time.new(1969, 7, 4)
    end

    it "returns a Time object for mmddyyyy" do
      text = "07041969"
      result = TextParser.parse_date(text)
      result.should == Time.new(1969, 7, 4)
    end
    
    it "handles 2 digit years" do
      text = "7/4/69"
      result = TextParser.parse_date(text)
      result.should == Time.new(1969, 7, 4)
    end

    it "handles 2 digit years" do
      text = "070469"
      result = TextParser.parse_date(text)
      result.should == Time.new(1969, 7, 4)
    end

  end
end
