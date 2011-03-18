class TextParser
  def self.parse_date(text)
    result = nil
    begin
      result = Chronic.parse(text)
    rescue TypeError
      # noop
    end
    puts "result: #{result}"
    if result.nil?
      if text =~ /^\d{8}$/
        try_text = "#{text[0..1]}/#{text[2..3]}/#{text[4..7]}"
        result = Chronic.parse(try_text)
      elsif text =~ /^\d{6}$/
        try_text = "#{text[0..1]}/#{text[2..3]}/#{text[4..5]}"
        result = Chronic.parse(try_text)
      end
    end
    if !result.nil?
      if result.year < 100
        result += 1900.years
      end
      result.at_beginning_of_day
    end
  end
end
