require 'spec_helper'

describe TextParser do
  
  describe "#remove_extra_lines" do
    it "handles text footers correctly" do
      text = "Address\n- This is my footer!!! -"
      result = TextParser.remove_extra_lines(text)
      result.should == "Address"
    end
  end
  
  describe "#parse_date" do

    it "handles canonical US date format (mm/dd/yyyy)" do
      text = "3/8/1972"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
    end

    it "handles canonical US date format with two digit years (mm/dd/yy)" do
      text = "3/8/72"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
    end

    it "handles all digits with four digit years (mmddyyyy)" do
      text = "03081972"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
    end

    it "handles all digits with two digit years" do
      text = "030872"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
    end
    
    it "handles all digits with spaces as separators" do
      text = "03 08 1972"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
    end

    it "handles all digits with any non-alpha characters as separators" do
      text = "03*08*1972"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
    end

    it "any non-alphanumeric character is treated as a separator" do
      text = "3*8*1972"
      result = TextParser.parse_date(text)
      result.should == Time.new(1972, 3, 8)
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
  
  describe "#parse_address" do
    
    it "returns already normalized addresses without modification" do
      address = "101 S MAIN"
      result = TextParser.parse_address(address)
      result.should == address
    end

    it "removes fractions" do
      address = "101 1/2 S MAIN ST"
      expected = "101 S MAIN"
      result = TextParser.parse_address(address)
      result.should == expected
    end

    it "handles crazy court" do
      address = "101 S MAIN C.T."
      expected = "101 S MAIN"
      result = TextParser.parse_address(address)
      result.should == expected
    end

    it "removes everything after secondary unit designator, including the designator" do
      address = "101 S MAIN ST APT 5"
      expected = "101 S MAIN"
      result = TextParser.parse_address(address)
      result.should == expected
    end

    it "treats # as a secondary unit designator" do
      address = '101 S MAIN #5'
      expected = "101 S MAIN"
      result = TextParser.parse_address(address)
      result.should == expected
    end

    it "treats # as a secondary unit designator" do
      address = '101 S. MAIN ST.'
      expected = "101 S. MAIN"
      result = TextParser.parse_address(address)
      result.should == expected
    end

    it "finds place" do
      address = '101 Floyd Pl'
      expected = "101 Floyd"
      result = TextParser.parse_address(address)
      result.should == expected
    end

  end
end
