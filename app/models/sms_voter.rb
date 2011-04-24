class SmsVoter < Voter
  before_create :assure_single_sms_voter

  attr_accessor :last_summary, :last_prompt, :has_unrecognized_response,
  :include_summary_on_failure, :fail_message

  include SmsVoterLookupStateMachine
  include SmsVoterHelpStateMachine

  FAKE_PHONE_NUMBER = "DONOTSEND"

  state_machine :conversation_status, :initial => :voter_lookup, :namespace => "conversation" do
    after_transition any => :help do |sms_user, transition|
      sms_user.user.asked_for_help
    end

    event :reset do
      transition any => :voter_lookup
    end

    event :voter_lookup do
      transition any => :voter_lookup
    end

    event :help_request do
      transition any => :help
    end

    state :voter_lookup
    state :help
  end

  def process_message(message) 
    save_message(message)
    message = TextParser.remove_extra_lines(message)
    # This is a hack, but all hell breaks loose if message is null
    message = "" if message.blank?
    message.strip!

    self.help_request_conversation if message.downcase == "help"

    if ["reset", "start over", "so"].include? message.downcase
      self.voter_lookup_conversation
      self.reset_help
      self.reset
    end

    self.stop if message.downcase == "stop"

    if self.conversation_status?(:help)
      self.transition_help
      self.last_summary = self.help_summary.strip
      self.last_prompt = self.help_prompt
    else
      process_message_by_status(message)
      self.last_summary = self.summary
      self.last_prompt = self.prompt
    end

    if self.has_unrecognized_response || !self.fail_message.nil?
      fail_message = self.fail_message || "Sorry, I didn't understand that."
      if self.include_summary_on_failure == true
        self.last_summary = "#{fail_message}\n#{self.last_summary}"
      else
        self.last_summary = fail_message
      end
    end

    return self.last_summary.kind_of?(Array) ? self.last_summary : "#{self.last_summary.strip}\n\n#{self.last_prompt}"
  end

  def assure_single_sms_voter
    unless user.sms_voter.nil?
      user.sms_voter.update_attribute(:type => nil)
    end
  end

  def reset_all!
    self.first_name = nil
    self.last_name = nil
    self.date_of_birth = nil
    self.address_line_1 = nil
    self.address_line_2 = nil
    self.city = nil
    self.zip = nil
    self.polling_place_id = nil
    self.county_clerk_id = nil
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
      :phone_number => FAKE_PHONE_NUMBER,
      :date_of_birth => 20.years.ago}.merge(attrs)
  end

  def first_welcome_message
    # 126 Characters
    "Welcome!  This will take just a minute and 5-10 text messages.  All info you provide is kept strictly confidential."
  end

  def no_voter_record_found_but_voter_confirms_they_have_voted_message
    # 132 Characters
    "Let's try again.  Make sure to use your full first name as you would when voting.  Example: Gregory, not Greg.  Katherine, not Katy."
  end
  
  def no_scheduled_elections
    "Based on your address, there are no upcoming elections scheduled. We'll let you know in the future when there are. Thanks for using VoteSimple.  "
  end

  def happy_path_message_one
    # These could approach the 160 character limit
    county_clerk_description = "(County clerk not found)"
    if self.county_clerk
      county_clerk_description = self.county_clerk.sms_description
    end
    if self.is_registered?
      "You can absentee vote any business day until #{self.next_election_date} at #{county_clerk_description}"
    else
      "You can register AND vote any business day until #{self.next_election_date} at #{county_clerk_description}"
    end
  end

  def happy_path_message_two
    # These could approach the 160 character limit
    polling_place_description = "(Polling place not found)"
    if self.polling_place
      polling_place_description = self.polling_place.sms_description
    end
    if self.is_registered?
      "On #{self.next_election_date} you can vote at #{polling_place_description}"
    else
      "On #{self.next_election_date} you can register AND vote at #{polling_place_description}"
    end
  end

  def happy_path_message_three
    county_clerk_phone = "Phone not found"
    if self.county_clerk && self.county_clerk.phone_number
      county_clerk_phone = self.county_clerk.phone_number
    end
    "More help? Call your county clerk @ #{county_clerk_phone} OR text back 'HELP' and we'll give you a call."
  end

  def invite_a_friend_message
    # TODO: Send this after we find out they've submitted absentee ballot?  Or maybe a day after they get to the happy path end using a background process?
     "Invite your friends to use VoteSimple.  Just text us 'Invite' and their phone number and we'll send them a text. Thanks!"
  end

  def address_confirmation_summary
        address = self.address_line_1
        if self.address_line_2
          address = "#{address}\n#{self.address_line_2}"
        end
        <<-eof
You are currently registered at:

#{address.titleize}, #{self.city.titleize}
        eof
    end

    private

    def save_message(message)
      incoming_messages.create!(:text => message)
    end
end
