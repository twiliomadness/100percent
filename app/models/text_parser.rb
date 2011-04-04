class TextParser
  def self.parse_date(text)
    result = nil
    begin
      result = Chronic.parse(text)
    rescue TypeError
      # noop
    end
    # 8 digits e.g., 03081972 -> 3/8/1972
    if result.nil? && text =~ /^\d{8}$/
      try_text = "#{text[0..1]}/#{text[2..3]}/#{text[4..7]}"
      result = Chronic.parse(try_text)
    end
    # 6 digits; e.g., 030872 -> 3/8/1972
    if result.nil? && text =~ /^\d{6}$/
      try_text = "#{text[0..1]}/#{text[2..3]}/#{text[4..5]}"
      result = Chronic.parse(try_text)
    end
    # non-alphanumeric separators
    if result.nil? && text =~ /([0-9]+[^a-z0-9])+/i
      try_text = text.gsub(/[^\d]/, '/')
      result = Chronic.parse(try_text)
    end
    if !result.nil?
      if result.year < 100
        result += 1900.years
      end
      result.at_beginning_of_day
    end
  end
  
  def self.parse_yes_or_no(text)
    if text.downcase.starts_with?('y')
      'yes'
    elsif text.downcase.starts_with?('n')
      'no'
    else
      nil
    end
  end
  
  def self.parse_address(text)
    patterns = [["Strip fractions", /^(\d+ )(\d\/\d )?/, '\1'],
      ["Strip the secondary unit designators and anything following them", /^(.*? )(#|apartment|apt|basement|bldg|bsmt|building|department|dept|fl|floor|frnt|front|hangar|hngr|lbby|lobby|lot|lower|lowr|ofc|office|penthouse|ph|pier|rear|rm|room|side|slip|space|spc|ste|stop|suite|trailer|trlr|unit|upper|uppr)\b.*?$/i, '\1'],
      ["Strip everything after the street designation", /^(.*? )(ave|avenue|blvd|boulevard|cir|circle|court|ct|dr|drive|freeway|frwy|highway|hwy|lane|ln|mews|parkway|place|pl|pike|pkwy|rd|road|st|street|trail|trl|way)\b.*?$/i, '\1']]
    result = text
    patterns.each do |description, pattern, replacement|
      result = result.sub(pattern, replacement)
    end
    result.strip
  end
  
  def self.normalize_whitespace(text)
    text.split.join(' ')
  end
end
