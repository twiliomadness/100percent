module SmsVoterLookupStateMachine
  def self.included(base)
    base.state_machine :status, :initial => :welcome do
      after_transition any => :pending_zip, :do => :lookup_address_via_geocode
      after_transition any => :pending_gab_voter_info_lookup, :do => :lookup_in_gab_by_voter_info
      after_transition any => :pending_voter_address_lookup, :do => :lookup_address
      before_transition any => :welcome, :do => :reset_all!

      event :reset do
        transition any => :welcome
      end

      event :stop do
        transition any => :stopped
      end

      event :next_prompt do
        transition :welcome => :pending_first_name

        #linear path to collect voter info
        #----------------------------------
        transition :pending_first_name => :pending_last_name
        transition :pending_last_name => :pending_date_of_birth
        transition :pending_date_of_birth => :pending_gab_voter_info_lookup

        #linear path to collect voter address
        #--------------------------------------
        transition :pending_address_line_1 => :pending_city
        transition :pending_city => :pending_zip
        transition :pending_zip => :pending_voter_address_lookup

        # Couldn't find address, so loop back to the start
        transition :voter_address_not_found_in_gab => :pending_address_line_1
        transition :voter_address_found => :happy_path_endpoint
      end

      event :branch_yes do
        transition :pending_voter_info_confirmation_retry => :need_help                             #user info not in gab, confirmed correct
        transition :pending_voter_history_confirmation => :pending_first_name                       #user has voted, must have mis-typed info
        transition :pending_voter_address_lookup => :voter_address_found                            #found voter
        transition :pending_gab_voter_info_lookup => :pending_gab_voter_address_confirmation        #found voter address
        transition :pending_gab_voter_address_confirmation => :voter_address_found                  #voter confirms this their GAB record
      end

      event :branch_no do
        transition [:pending_voter_info_confirmation,
                    :pending_voter_info_confirmation_retry] => :welcome                       #found wrong user in gab, try again
        transition :pending_voter_history_confirmation => :pending_address_line_1             #user not in gab, they have't voted, lookup polling place
        transition :pending_voter_address_lookup => :pending_address_line_1                   #cound not find users address in gab
        transition :pending_gab_voter_info_lookup => :pending_voter_history_confirmation      #could not find user in gab
        transition :pending_gab_voter_address_confirmation => :pending_address_line_1         #found voter, but not this users record
      end

      state :welcome do
        def process_message_by_status(message)
          self.outgoing_messages.create(:text => self.first_welcome_message)
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
          "At any point just text 'Reset' to start over. If you get totally stuck, text 'Help' and we'll contact you."
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
          "Great. To check if you're registered or can register, we need your date of birth. All info is kept confidential."
        end

        def prompt
          "What is your date of birth (mm/dd/yy)?"
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
          self.outgoing_messages.create :text => self.no_voter_record_found_but_voter_confirms_they_have_voted_message
          self.branch_yes
        end

        def summary
          "We couldn't find a record for you."
        end

        def prompt
          "Have you voted in Wisconsin before?"
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
        def summary
          ""
        end

        def prompt
          ""
        end
      end

      state :voter_address_not_found_in_gab do
        def summary
          "We couldn't find that address. Let's try again.  Text 'Help' to have a volunteer contact you."
        end

        def prompt
          ""
        end
      end

      state :pending_gab_voter_address_confirmation do
        validates_presence_of :address_line_1, :city, :zip
        def process_message_by_status(message)
          self.include_summary_on_failure = true
          transition_branch_yes_no(message, :yes => :process_yes, :no => :process_no)
        end
        def process_yes
          self.lookup_address
        end

        def process_no
          self.branch_no
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
          self.next_prompt
        end
        def summary
          [self.happy_path_message_one, self.happy_path_message_two, self.happy_path_message_three]
        end
        def prompt

        end
      end

      state :happy_path_endpoint do
        def process_message_by_status(message)
        end
        def summary
          ""
        end
        def prompt
          ""
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

      state :stopped do
        def process_message_by_status(message)
        end

        def summary
          ""
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
    if self.update_voter_polling_place_clerk
      self.branch_yes
    else
      self.outgoing_messages.create :text => "We couldn't find that address. Lets try again, or 'HELP' to have a volunteer contact you."
      self.branch_no
    end
  end

  def lookup_in_gab_by_voter_info
    voter_record = VoterRecord.find_by_name_and_date_of_birth(self.first_name, self.last_name, self.date_of_birth)
    if voter_record
      self.update_attributes_from_voter_record(voter_record)
      self.save
      self.branch_yes
    else
      self.branch_no
    end
  end

  def lookup_address_via_geocode
    result = Geokit::Geocoders::GoogleGeocoder.geocode("#{self.address_line_1}, #{self.city}, WI")
    if result.success && result.all.size == 1
      self.zip = result.zip
      self.next_prompt
    end
  end

end
