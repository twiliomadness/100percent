class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # TODO: Add :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :phone_number

  # TODO: Once :token_authenticatable is added, re-enable this:
  # before_save :reset_authentication_token

  has_many :incoming_messages

  # TODO: help, quit, reset, back, other verbs?

  state_machine :status, :initial => :welcome do
    event :start_collecting do
      transition :welcome => :pending_first_name
    end
    
    event :save_first_name do
      transition :pending_first_name => :pending_last_name
    end

    event :save_last_name do
      transition :pending_last_name => :pending_date_of_birth
    end

    event :save_date_of_birth do
      transition :pending_date_of_birth => :pending_voter_info_confirmation
    end

    event :confirm_voter_info do
      transition :pending_voter_info_confirmation => :pending_address_confirmation
    end
    
    event :confirm_address do
      transition :pending_address_confirmation => :address_confirmed
    end

    state :welcome do
      def process_message_by_status(message)
        # noop
      end
      def summary
        # noop
      end
      def prompt
        # noop
      end
    end

    state :pending_first_name do
      def process_message_by_status(message)
        self.first_name = message.strip
      end
      def summary
        "Welcome!"
      end
      def prompt
        "What is your first name?"
      end
    end

    state :pending_last_name do
      validates_presence_of :first_name
      def process_message_by_status(message)
        self.last_name = message.strip
      end
      def summary
        "Thanks, #{self.first_name}"
      end
      def prompt
        "What is your last name?"
      end
    end

    state :pending_date_of_birth do
      validates_presence_of :last_name
      def process_message_by_status(message)
        self.date_of_birth = TextParser.parse_date(message)
      end
      def summary
        "OK, #{self.full_name}"
      end
      def prompt
        "What is your date of birth (mm/dd/yyyy)?"
      end
    end
    
    state :pending_voter_info_confirmation do
      validates_presence_of :date_of_birth
      def process_message_by_status(message)
        # noop
      end
      def sms_yes
        # TODO: Log?
        result = self.search_for_voter_record
        logger.info("Searched for voter record result: #{result}")
        nil
      end
      def sms_no
        # TODO: This seems drastic, but not sure what else to do.
        self.reset_all!
        nil
      end
      def summary
        "We have:\n#{self.full_name}\n#{self.date_of_birth_friendly}"
      end
      def prompt
        "Is this correct? Yes or No"
      end
    end

    state :pending_address_confirmation do
      validates_presence_of :address_line_1, :city, :zip
      def process_message_by_status(message)
        # noop
      end
      def sms_yes
        # TODO: Get the polling place.
      end
      def sms_no
        self.reset_address!
        nil
      end
      def summary
        address = self.address_line_1
        if self.address_line_2
          address = "#{address}\n#{self.address_line_2}"
        end
        <<-eof
You are currently registered at:

#{address}
#{self.city} #{self.zip}
        eof
      end
      def prompt
        "Is this your current address?"
      end
    end
    
    state :address_confirmed do
      def process_message_by_status(message)
      end
      def summary
        "Thanks for confirming your address!"
      end
      def prompt
        "No more steps for now"
      end
    end
  end

  
  def sms_help
    "You can send: help, reset, status"
  end

  def sms_reset
    reset_all!
    "Reset"
  end
  
  def sms_resetaddress
    reset_address!
    nil
  end

  def sms_status
    "Current status: #{self.human_status_name}"
  end

  def reset_address!
    self.address_line_1 = nil
    self.address_line_2 = nil
    self.city = nil
    self.zip = nil
    self.status = "pending_voter_info_confirmation"
    self.save!
  end
  
  def reset_all!
    self.first_name = nil
    self.last_name = nil
    self.date_of_birth = nil
    self.address_line_1 = nil
    self.address_line_2 = nil
    self.city = nil
    self.zip = nil
    self.status = "welcome"
    self.save!
  end

  def process_message(message)
    message.strip!
    save_message(message)
    # This is for things like:  reset, help, quit, status, back
    message_as_method = "sms_#{message.downcase}"
    summary_text = nil
    if self.respond_to?(message_as_method)
      summary_text = self.send(message_as_method)
    else
      process_message_by_status(message)
    end
    # TODO: Do we ever have more than one valid transition?
    next_event = status_transitions.first
    if !next_event.nil?
      # For each transition, check can_#{transition}?
      self.send(next_event.event)
    end
    save
    summary_text ||= self.summary
    # TODO: Save outgoing messages?
    # TODO: Check for character limit (160).
    "#{summary_text.strip}\n\n#{prompt}"
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def date_of_birth_friendly
    if date_of_birth
      date_of_birth.strftime('%B %d, %Y')
    end
  end

  def search_for_voter_record
    agent = Mechanize.new

    page = agent.get(APP_CONFIG[:VOTER_SEARCH_URL])

    # Fill out the login form
    form = page.form_with(:name => 'Form1')
    form.txtLastName = self.last_name
    form.txtFirstName = self.first_name
    form.txtDateOfBirth = self.date_of_birth.strftime("%m/%d/%Y")
    
    page = form.click_button
    
    result_page = Nokogiri.HTML(page.content)

    # Another approach is to look for links with href that contains VoterSummaryScreen in the link
    path = "//a[text() = '#{self.full_name.upcase}']"
    
    link = result_page.xpath(path)
    if link.present?
      # TODO: Handle possibility of more than one record
      url = link.first.get_attribute("href")
      next_page = page.link_with(:href => url).click
      voter_info = Nokogiri.HTML(next_page.content)
      user_address_line_1 = voter_info.xpath("//input[@id = 'txtAddressLine1']").first.get_attribute("value")
      user_address_line_2 = voter_info.xpath("//input[@id = 'txtAddressline2']").first.get_attribute("value")
      user_city = voter_info.xpath("//input[@id = 'txtCity']").first.get_attribute("value")
      user_zip = voter_info.xpath("//input[@id = 'txtZipcode']").first.get_attribute("value")
      
      if self.address_line_1.blank?
        self.address_line_1 = user_address_line_1
      end
      if self.address_line_2.blank?
        self.address_line_2 = user_address_line_2
      end
      if self.city.blank?
        self.city = user_city
      end
      if self.zip.blank?
        self.zip = user_zip
      end
      self.save
    end
    
  end
  
  private

    def save_message(message)
      incoming_messages.create!(:text => message)
    end

end
