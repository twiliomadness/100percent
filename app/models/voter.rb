class Voter 

  attr_accessor :address_line_1, :address_line_2, :city, :zip
  
  def self.default_attributes(attrs = {})
    {:address_line_1 => "123 MAIN ST.",
      :city => "MADISON",
      :zip => "53703"}.merge(attrs)
  end
    
  def self.find_by_name_and_date_of_birth(first_name, last_name, date_of_birth)
    # TODO: Record all searches, use as cache, etc.
    agent = Mechanize.new

    page = agent.get(APP_CONFIG[:VOTER_SEARCH_URL])

    form = page.form_with(:name => 'Form1')
    form.txtLastName = last_name
    form.txtFirstName = first_name
    form.txtDateOfBirth = date_of_birth.strftime("%m/%d/%Y")
    
    page = form.click_button
    
    result_page = Nokogiri.HTML(page.content)

    # Another approach is to look for links with href that contains VoterSummaryScreen in the link
    path = "//a[starts-with(@href, 'VoterSummaryScreen')]"

    links = result_page.xpath(path)
    if links.empty?
      return nil
    end

    # TODO: Handle possibility of more than one record

    link = links.first

    url = link.get_attribute("href")
    next_page = page.link_with(:href => url).click
    voter_info = Nokogiri.HTML(next_page.content)

    address_line_1 = voter_info.xpath("//input[@id = 'txtAddressLine1']").first.get_attribute("value")
    address_line_2 = voter_info.xpath("//input[@id = 'txtAddressline2']").first.get_attribute("value")
    city = voter_info.xpath("//input[@id = 'txtCity']").first.get_attribute("value")
    zip = voter_info.xpath("//input[@id = 'txtZipcode']").first.get_attribute("value")

    Voter.new(:address_line_1 => address_line_1, :address_line_2 => address_line_2, :city => city, :zip => zip)

  end
end
