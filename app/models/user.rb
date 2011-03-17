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
  # TODO: Using :state as the state_machine field conflicts with :state as in Wisconsin

  state_machine :state, :initial => :welcome do
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
      transition :pending_date_of_birth => :pending_voter_search
    end

    state :welcome do
      def process_message_by_state(message)
        # noop
      end
      def prompt
        "First Name?"
      end
    end

    state :pending_first_name do
      def process_message_by_state(message)
        self.first_name = message.strip
      end
      def prompt
        "First Name?"
      end
    end

    state :pending_last_name do
      validates_presence_of :first_name
      def process_message_by_state(message)
        self.last_name = message.strip
      end
      def prompt
        "Last Name?"
      end
    end

    state :pending_date_of_birth do
      validates_presence_of :last_name
      def process_message_by_state(message)
        self.date_of_birth = Time.parse(message)
      end
      def prompt
        "Date of Birth?"
      end
    end

    state :pending_voter_search do
      validates_presence_of :date_of_birth
      def process_message_by_state(message)
        # noop
      end
      def prompt
        "Next step is not yet implemented"
      end
    end
  end

  def process_message(message)
    save_message(message)
    # TODO: Check whether message is non-state specific (e.g., help, quit, status, etc.)
    process_message_by_state(message)
    # TODO: Do we ever have more than one valid transition?
    next_event = state_transitions.first
    if !next_event.nil?
      self.send(next_event.event)
    end
    save
    # TODO: Save outgoing messages?
    prompt
  end
  
  def summary
    # TODO: Trim whitespace
    <<-eof
Here's what we have so far:

First Name: #{self.first_name}
Last Name: #{self.last_name}
Date of Birth: #{self.date_of_birth}
    eof
  end

  private

    def save_message(message)
      incoming_messages.create!(:text => message)
    end

end
