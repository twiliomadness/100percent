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

  state_machine :state, :initial => :pending_first_name do
    event :save_first_name do
      transition :pending_first_name => :pending_last_name
    end

    event :save_last_name do
      transition :pending_last_name => :pending_date_of_birth
    end

    event :save_date_of_birth do
      transition :pending_date_of_birth => :pending_voter_search
    end

    state :pending_first_name do
      def process_message(message)
        save_message(message)
        self.first_name = message.strip
        if self.valid?
          save_first_name
          self.save!
          'Last Name?'
        else
          'oops, try again; First Name?'
        end
      end
    end

    state :pending_last_name do
      validates_presence_of :first_name
      def process_message(message)
        save_message(message)
        self.last_name = message.strip
        if self.valid?
          save_last_name
          self.save!
          'Date of Birth?'
        else
          'oops, try again; Last Name?'
        end
      end
    end
    
    state :pending_date_of_birth do
      validates_presence_of :last_name
      def process_message(message)
        save_message(message)
        self.date_of_birth = Time.parse(message)
        if self.valid?
          save_date_of_birth
          self.save!
          'done for now'
        else
          'oops, try again; Date of Birth?'
        end
      end
    end
    
    state :pending_voter_search do
      validates_presence_of :date_of_birth
    end
  end

  private
  
    def save_message(message)
      incoming_messages.create!(:text => incoming_text)
    end

end
