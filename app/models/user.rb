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
    
    event :failed_voter_lookup do
      transition :pending_voter_info_confirmation => :pending_voter_history_confirmation
    end
    
    event :confirmed_voting_history do
      transition :pending_voter_history_confirmation => :pending_voter_info_confirmation_retry
    end
    
    event :confirmed_voting_history_but_unable_to_find do
      transition :pending_voter_info_confirmation_retry => :pending_assistance_finding_voter_record
    end
    
    event :confirmed_nonvoting_history do
      transition :pending_voter_history_confirmation => :pending_address_line_1
    end
    
    event :save_address_line_1 do
      transition :pending_address_line_1 => :pending_city
    end
    
    event :save_city do
      transition :pending_city => :pending_zip
    end
    
    event :save_zip do
      transition :pending_zip => :pending_address_confirmation
    end

    event :confirm_voter_info do
      transition :pending_voter_info_confirmation => :pending_address_confirmation
    end
    
    event :confirm_address do
      transition :pending_address_confirmation => :address_confirmed
    end

    state :welcome do
      def process_message_by_status(message)
        start_collecting
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
        save_first_name
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
        save_last_name
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
        save_date_of_birth
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
        try_text = TextParser.parse_yes_or_no(message)
        if !try_text.nil?
          case try_text
          when "yes"
            self.process_yes
          when "no"
            self.process_no
          end
        end
      end

      def process_yes
        voter = Voter.find_by_name_and_date_of_birth(self.first_name, self.last_name, self.date_of_birth)
        if voter
          self.address_line_1 = voter.address_line_1
          self.address_line_2 = voter.address_line_2
          self.city = voter.city
          self.zip = voter.zip
          self.confirm_voter_info
        else
          self.failed_voter_lookup
        end
      end
      def process_no
        # TODO: This seems drastic, but not sure what else to do.
        self.reset_all!
      end
      def summary
        "We have:\n#{self.full_name}\n#{self.date_of_birth_friendly}"
      end
      def prompt
        "Is this correct? Yes or No"
      end
    end
    
    state :pending_voter_history_confirmation do
      def process_message_by_status(message)
        try_text = TextParser.parse_yes_or_no(message)
        if !try_text.nil?
          case try_text
          when "yes"
            self.process_yes
          when "no"
            self.process_no
          end
        end
      end
      def process_yes
        self.confirmed_voting_history
      end
      def process_no
        self.confirmed_nonvoting_history
      end
      def summary
        "We were unable to find a voting record for #{self.full_name} dob #{self.date_of_birth_friendly}"
      end
      def prompt
        "Have you voted in Wisconsin before? Yes or No"
      end
    end
    
    state :pending_voter_info_confirmation_retry do
      def process_message_by_status(message)
        try_text = TextParser.parse_yes_or_no(message)
        if !try_text.nil?
          case try_text
          when "yes"
            self.process_yes
          when "no"
            self.process_no
          end
        end
      end
      def process_yes
        self.confirmed_voting_history_but_unable_to_find
      end
      def process_no
        self.reset_all!
      end
      def summary
        "We were unable to find a voting record for #{self.full_name} dob #{self.date_of_birth_friendly}"
      end
      def prompt
        "Plese verify your record? Yes or No"
      end
    end
    
    state :pending_assistance_finding_voter_record do
      def process_message_by_status(message)
        # noop
      end
      def summary
        "We were unable to find a voting record for #{self.full_name} dob #{self.date_of_birth_friendly}"
      end
      def prompt
        "One of our volunteers will contact you"
      end
    end
    
    state :pending_address_line_1 do
      def process_message_by_status(message)
        self.address_line_1 = message
        self.save_address_line_1
      end
      def summary
        ""
      end
      def prompt
        "What is your street address?"
      end
    end

    state :pending_city do
      validates_presence_of :address_line_1
      def process_message_by_status(message)
        self.city = message
        self.save_city
      end
      def summary
        "Your street address is #{self.address_line_1}"
      end
      def prompt
        "What is your city?"
      end
    end

    state :pending_zip do
      validates_presence_of :address_line_1, :city
      def process_message_by_status(message)
        self.zip = message
        self.save_zip
      end
      def summary
        "Your city is #{self.city}"
      end
      def prompt
        "What is your zip?"
      end
    end

    state :pending_address_confirmation do
      validates_presence_of :address_line_1, :city, :zip
      def process_message_by_status(message)
        try_text = TextParser.parse_yes_or_no(message)
        if !try_text.nil?
          case try_text
          when "yes"
            self.process_yes
          when "no"
            self.process_no
          end
        end
      end
      def process_yes
        # TODO: Get the polling place.
      end
      def process_no
        # TODO: This seems drastic.
        self.reset_address!
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
        "Is this your current address? Yes or No"
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
    "Your record was reset"
  end
  
  def sms_resetaddress
    reset_address!
    "Your address was reset"
  end

  def sms_status
    "Your current status is '#{self.human_status_name}'"
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
    outgoing_text = nil
    if self.respond_to?(message_as_method)
      outgoing_text = self.send(message_as_method)
    else
      process_message_by_status(message)
    end

    save

    # TODO: Save outgoing messages?
    # TODO: Check for character limit (160).
    
    if outgoing_text
      outgoing_text
    else
      "#{self.summary.strip}\n\n#{prompt}"
    end
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def date_of_birth_friendly
    if date_of_birth
      date_of_birth.strftime('%B %d, %Y')
    end
  end

  def self.default_attributes(attrs = {})
    {:first_name => "John",
      :last_name => "Smith",
      :phone_number => "+15555551111",
      :date_of_birth => 20.years.ago}.merge(attrs)
  end
  
  private

    def save_message(message)
      incoming_messages.create!(:text => message)
    end

end
