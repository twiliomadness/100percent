module SmsVoterLookupStateMachine
  def self.included(base)
    base.state_machine :status, :initial => :welcome do
      after_transition any => :pending_gab_voter_info_lookup, :do => :lookup_in_gab_by_voter_info
      after_transition any => :pending_voter_address_lookup, :do => :lookup_address
      before_transition any => :welcome, :do => :reset_all!
        
      event :reset do 
        transition any => :welcome
      end

      event :next_prompt do
        transition :welcome => :pending_first_name
        transition :pending_first_name => :pending_last_name
        transition :pending_last_name => :pending_date_of_birth
        transition :pending_date_of_birth => :pending_gab_voter_info_lookup
        transition :pending_gab_voter_info_lookup => :pending_gab_voter_address_confirmation
        transition :pending_address_line_1 => :pending_city
        transition :pending_city => :pending_zip
        transition :pending_zip => :pending_voter_address_lookup
        transition [:pending_gab_voter_address_confirmation, :pending_voter_address_lookup] => :voter_address_found 
      end

      event :branch_yes do
        transition :pending_user_entered_voter_address_confirmation => :unknown_address_needs_volunteer_help
        transition :pending_voter_info_confirmation_retry => :need_help
        transition :pending_voter_history_confirmation => :pending_first_name
      end

      event :branch_no do
        transition [:pending_user_entered_voter_address_confirmation, :pending_voter_has_voted_before_in_wisconsin_confirmation] => :pending_address_line_1
        transition [:pending_voter_info_confirmation, :pending_voter_info_confirmation_retry] => :welcome
      end

      event :failed_voter_name_and_dob_lookup do
        transition any => :pending_voter_history_confirmation
      end
      
      event :failed_user_entered_voter_address_lookup do
        transition any => :pending_user_entered_voter_address_confirmation
      end
  
  
      state :welcome do
        def process_message_by_status(message)
          self.next_prompt
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
          self.update_attribute(:first_name, message.strip)
          if self.first_name
            self.next_prompt
          else
            self.has_unrecognized_response = true
          end
        end
        def summary
          "At any point you can reply 'Reset' to start over.  Also, if you get totally stuck, just reply 'Help' and we'll give you a call."
        end
        def prompt
          "Ok, What is your full first name?"
        end
      end
  
      state :pending_last_name do
        def process_message_by_status(message)
          self.last_name = message.strip
          if self.last_name.blank?
            self.has_unrecognized_response = true
          else
            self.next_prompt if self.valid?
          end
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
          if self.date_of_birth
            self.next_prompt
          else
            self.has_unrecognized_response = true
          end
        end
  
        def summary
          "OK, #{self.full_name}"
        end
  
        def prompt
          "What is your date of birth (mm/dd/yyyy)?"
        end
      end
      
      state :pending_gab_voter_info_lookup do
        def summary 
          ""
        end

        def prompt
          ""
        end
      end

      state :pending_voter_history_confirmation do
        def process_message_by_status(message)
          transition_branch_yes_no(message, :yes => :process_yes)
        end
        def process_yes
          self.fail_message = "Let's try agian"
          self.branch_yes
        end

        def summary
          "We couldn't find a record for you."
        end
        
        def prompt
          "Have you voted in Wisconsin before?"
        end
      end
        
      state :pending_voter_info_confirmation do
        validates_presence_of :date_of_birth
        def process_message_by_status(message)
          self.include_summary_on_failure = true
          transition_branch_yes_no(message, :yes => :process_yes)
        end
  
        def process_yes
          voter = VoterRecord.find_by_name_and_date_of_birth(self.first_name, self.last_name, self.date_of_birth)
          if voter
            self.update_attributes_from_voter(voter)
            self.save
            self.next_prompt
          else
            self.failed_voter_name_and_dob_lookup
          end
        end

        def summary
          "We have:\n#{self.full_name}\n#{self.date_of_birth_friendly}"
        end
        def prompt
          "Is this correct? Yes or No"
        end
      end
      
      state :pending_voter_info_confirmation_retry do
        def process_message_by_status(message)
          self.include_summary_on_failure = true
          transition_branch_yes_no(message)
        end
        def summary
          "We were unable to find a voting record for #{self.full_name} dob #{self.date_of_birth_friendly}"
        end
        def prompt
          "Please verify your record? Yes or No"
        end
      end
      
      state :pending_address_line_1 do
        def process_message_by_status(message)
          self.address_line_1 = message
          if self.address_line_1.to_s.blank?
            self.has_unrecognized_response = true
          else
            self.next_prompt
          end
        end
        def summary
          "Next step is to determine where you vote."
        end
        def prompt
          "What is your street address?"
        end
      end
  
      state :pending_city do
        validates_presence_of :address_line_1

        def process_message_by_status(message)
          self.city = message.strip
          if self.city.to_s.blank?
            self.has_unrecognized_response = true
          else
            self.next_prompt 
          end
        end

        def summary
          "Got it."
        end

        def prompt
          "City?"
        end
      end
  
      state :pending_zip do
        validates_presence_of :address_line_1, :city
        def process_message_by_status(message)
          self.zip = message
          if self.zip.to_s.blank?
            self.has_unrecognized_response = true
          else
            self.next_prompt
          end
        end

        def summary
          "OK."
        end

        def prompt
          "Zip?"
        end
      end
  
      state :pending_voter_address_lookup do 
        validates_presence_of :address_line_1, :city, :zip
        def summary
          ""
        end
  
        def prompt
          ""
        end
      end
  
      state :pending_gab_voter_address_confirmation do
        validates_presence_of :address_line_1, :city, :zip
        def process_message_by_status(message)
          self.include_summary_on_failure = true
          transition_branch_yes_no(message, :yes => :process_yes, :no => :failed_voter_name_and_dob_lookup)
        end
        def process_yes
          self.update_voter_address
          self.voter_address_saved
        end
        def process_no
          self.failed_voter_name_and_dob_lookup
        end
  
        def summary
          self.address_confirmation_summary
        end

        def prompt
          "Is this your current address? Yes or No"
        end
      end
      
      state :pending_voter_has_voted_before_in_wisconsin_confirmation do 
        def process_message_by_status(message)
          transition_branch_yes_no(message)
        end
        
        def process_yes
          self.update_voter_address
          self.voter_address_saved
        end
        def process_no
          self.failed_voter_name_and_dob_lookup
        end
  
        def summary
          self.address_confirmation_summary
        end
        
        def prompt
          "Have you voted in Wisconsin before?"
        end
      end
      
      state :pending_user_entered_voter_address_confirmation do 
        def process_message_by_status(message)
          transition_branch_yes_no(message)
        end
  
        def summary
          self.address_confirmation_summary
        end
        
        def prompt
          "Is this your current address? Yes or No"
        end
      end
  
      state :voter_address_found do
        def process_message_by_status(message)
        end
        def summary
          "You are registered to vote at: #{self.polling_place.sms_description}"
        end
        def prompt
          "No more steps for now"
        end
      end
  
      state :need_help do
        def summary
          "A volunteer will contact you shortly"
        end
  
        def prompt
          ""
        end
      end
  
      state :unknown_address_needs_volunteer_help do
        def summary
          "We can't find your address in the database. So, a volunteer will contact you shortly to help out."
        end
  
        def prompt
          ""
        end
      end
      
    end
  end
  
  def transition_branch_yes_no(message, callbacks = {})
    try_text = TextParser.parse_yes_or_no(message)
    unless try_text.nil?
      case try_text
      when "yes"
        callbacks.has_key?(:yes) ? self.send(callbacks[:yes].intern) : self.branch_yes
      when "no"
        callbacks.has_key?(:no) ? self.send(callbacks[:no].intern) : self.branch_no
      end
    else
      self.has_unrecognized_response = true
    end
  end

  def lookup_address
    # If this address is not found, returns false
    if self.update_voter_address
      self.next_prompt
    else  
      self.failed_user_entered_voter_address_lookup
    end
  end

  def lookup_in_gab_by_voter_info
    voter = VoterRecord.find_by_name_and_date_of_birth(self.first_name, self.last_name, self.date_of_birth)
    if voter
      self.address_line_1 = voter.address_line_1
      self.address_line_2 = voter.address_line_2
      self.city = voter.city
      self.zip = voter.zip
      self.save
      self.next_prompt
    else
      self.failed_voter_name_and_dob_lookup
    end
  end

end
