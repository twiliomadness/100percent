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
  
  describe "#parse_yes_or_no" do

    it "returns nil when unable to parse yes or no" do
      text = "maybe"
      result = TextParser.parse_yes_or_no(text)
      result.should be_nil
    end

    it "returns 'yes' for text that looks like yes" do
      options = ['Yes', 'y', 'Y', 'Yup']
      options.each do |text|
        result = TextParser.parse_yes_or_no(text)
        result.should == 'yes'
      end
    end

    it "returns 'no' for text that looks like yes" do
      options = ['No', 'n', 'N', 'Nah']
      options.each do |text|
        result = TextParser.parse_yes_or_no(text)
        result.should == 'no'
      end
    end

  end
end
