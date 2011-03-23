class SmsVoter < Voter
  before_create :assure_single_sms_voter
  
  attr_accessor :last_summary, :last_prompt

  include SmsVoterLookupStateMachine
  include SmsVoterHelpStateMachine

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
    # TODO: Somewhere we should have a begin/rescue block; ideally outermost and just say,
    # "Oops, I did not understand that.  Can we try again"
    # We need a "restate" global method.

    message.strip!
    save_message(message)

    self.help_request_conversation if message.downcase == "help"    

    if ["reset", "start over", "so"].include? message.downcase
      self.voter_lookup_conversation
      self.reset_help
      self.reset
    end

    if self.conversation_status?(:help)
      self.transition_help      
      self.last_summary = self.help_summary.strip
      self.last_prompt = self.help_prompt
    else
      process_message_by_status(message)
      self.last_summary = self.summary.strip
      self.last_prompt = self.prompt
    end
    return "#{self.last_summary.strip}\n\n#{self.last_prompt}"
  end


  def assure_single_sms_voter
    unless user.sms_voter.nil?
      user.sms_voter.update_attribute(:type => nil)
    end
  end

  def reset_address!
    self.address_line_1 = nil
    self.address_line_2 = nil
    self.city = nil
    self.zip = nil
    self.status = "pending_address_line_1"
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

  def update_attributes_from_voter(voter)
   self.address_line_1 = voter.address_line_1
   self.address_line_2 = voter.address_line_2
   self.city = voter.city
   self.zip = voter.zip
  end

  def address_confirmation_summary
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

    private

    
    def save_message(message)
      incoming_messages.create!(:text => message)
    end
end
