require 'spec_helper'

describe CountyClerk do
  describe "#self.get_clerk" do
    it "should blah blah" do
      filename = File.join(File.dirname(__FILE__), "clerk_information.html")
      content = File.new(filename).read()
      CountyClerk.get_clerk_from_html(content, "Dane")
    end
  end
end
