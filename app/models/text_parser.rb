class TextParser
  def self.parse_date(text)
    result = Chronic.parse(text)
    if result.nil?
      if text =~ /^\d{8}$/
        try_text = "#{text[0..1]}/#{text[2..3]}/#{text[4..7]}"
        result = Chronic.parse(try_text)
        if result.nil?
        end
      end
    end
    result.at_beginning_of_day
  end
end
