module SmsVoterLookupStateMachine
  def self.included(base)
    base.state_machine :status, :initial => :welcome do
      after_transition any => :pending_voter_address_lookup, :do => :lookup_address
      before_transition any => :welcome, :do => :reset_all!
        
      event :reset do 
        transition any => :welcome
      end

      event :start_collecting do
        transition any => :pending_first_name
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
      
      event :failed_voter_name_and_dob_lookup do
        transition any => :pending_address_line_1
      end
      
      event :save_address_line_1 do
        transition :pending_address_line_1 => :pending_city
      end
      
      event :save_city do
        transition :pending_city => :pending_zip
      end
      
      event :save_zip do
        transition :pending_zip => :pending_voter_address_lookup
      end
  
      event :confirm_voter_info do
        transition :pending_voter_info_confirmation => :pending_gab_voter_address_confirmation
      end
      
      event :voter_address_saved do
        transition [:pending_gab_voter_address_confirmation, :pending_voter_address_lookup] => :voter_address_found 
      end
  
      event :failed_voter_address_lookup do
        transition :pending_voter_address_lookup => :pending_user_entered_voter_address_confirmation
      end
  
      event :confirmed_wrong_address_entered do 
        transition :pending_user_entered_voter_address_confirmation => :pending_address_line_1
      end
  
      event :confirmed_unknown_user_address_is_correct do 
        transition :pending_user_entered_voter_address_confirmation => :unknown_address_needs_volunteer_help
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
          voter = VoterRecord.find_by_name_and_date_of_birth(self.first_name, self.last_name, self.date_of_birth)
          if voter
            self.address_line_1 = voter.address_line_1
            self.address_line_2 = voter.address_line_2
            self.city = voter.city
            self.zip = voter.zip
            self.save
            self.confirm_voter_info
          else
            self.failed_voter_name_and_dob_lookup
          end
        end
        def process_no
          self.reset_all!
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
          "Please verify your record? Yes or No"
        end
      end
      
      state :pending_address_line_1 do
        def process_message_by_status(message)
          self.address_line_1 = message
          self.save_address_line_1
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
          self.city = message
          self.save_city
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
          self.save_zip
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
          process_yes_no_message(message)
        end
        def process_yes
          # We just got the address from the GAB in this path, so we could have assigned polling_place_id then.  This should still work.
          polling_place = VoterRecord.find_address_record(self.address_line_1, self.city, self.zip)
          self.update_attribute(:polling_place_id, polling_place.id)
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
      
      state :pending_user_entered_voter_address_confirmation do 
        def process_message_by_status(message)
          process_yes_no_message(message)
        end
  
        def process_yes
          self.confirmed_unknown_user_address_is_correct
        end
  
        def process_no
          self.confirmed_wrong_address_entered
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
          puts "Here we are!"
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
end
