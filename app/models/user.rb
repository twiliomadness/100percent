class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
      :phone_number, :volunteer, :on_call
      

  # TODO: Add :token_authenticatable, then re-enable this:
  # before_save :reset_authentication_token
  before_validation :create_password

  # Hopefully this is temporary. :)
  has_one :voter

  scope :has_email, :conditions => "length(email) > 0"
  scope :has_phone_number , :conditions => "length(phone_number) > 0"

  def self.default_attributes(attrs = {})
    {:first_name => "John",
      :email => "junk@votesimple.org",
      :password => "iamnotapotato",
      :last_name => "Smith"}.merge(attrs)
  end

  # We need to bypass the standard validation of email password for the sms voters
  def self.find_or_create_by_phone_number(number)
    user = User.find_by_phone_number(number)
    if user.nil?
      user = User.new
      user.phone_number = number
      # TODO: make sure this is a good way to handle this strangeness
      # Save w/o validation b/c we don't have email/password until later
      user.save(:validate => false)
    end
    user
  end

  state_machine :status, :initial => :new do
    event :asked_for_help do
      transition any => :needs_help
    end

    state :needs_help
  end
  
  def self.users_available_for_conference
    # TODO: max calls per hour, etc
    User.has_phone_number.find_all_by_on_call(true)
  end
  
  def set_volunteer_status(message)
    if message.present? && message.strip.downcase == "on"
      self.set_on_call
      "You are now on call"
    end
    if message.present? && message.strip.downcase == "off"
      self.set_to_not_on_call 
      "You are no longer on call"
    end
  end
  
  def set_on_call
    self.update_attribute(:on_call, true)
  end
  
  def set_to_not_on_call
    self.update_attribute(:on_call, false)
  end
  
protected
  def email_required?
    false 
  end

private
  
  def create_password
    if new_record? && password.blank?
      self.password = ActiveSupport::SecureRandom.hex(8)
    end
  end

end
