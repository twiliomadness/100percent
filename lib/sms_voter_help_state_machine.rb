module SmsVoterHelpStateMachine
  def self.included(base)
    base.state_machine :help_status, :initial => :initial_help_request, :namespace => "help" do
  
      after_transition :pending_issue_description => :pending_help_exit do |voter, transitoin|
        voter.reset_conversation
      end

      event :transition do
        transition :initial_help_request => :pending_issue_description
        transition :pending_issue_description => :pending_help_exit
        transition :pending_help_exit => :initial_help_request
      end

      event :reset do
        transition any => :initial_help_request
      end

      state :initial_help_request

      state :pending_issue_description do 
        def help_summary
          "Sorry you are having trouble"
        end

        def help_prompt
          "Please describe the issue"
        end
      end

      state :pending_help_exit do
        def help_summary
          "Thanks for your input.  A volunteer will contact you shortly."
        end

        def help_prompt
          "Text: start over, help"
        end
      end

    end
  end

end
