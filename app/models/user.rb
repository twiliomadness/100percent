class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :phone_number

  # TODO: Add :token_authenticatable, then re-enable this:
  # before_save :reset_authentication_token
  before_validation :create_password

  has_many :voters
  has_one :sms_voter, :conditions => {:type => 'SmsVoter'}
  has_one :voice_voter, :conditions => {:type => 'VoiceVoter'}
  has_one :web_voter, :conditions => {:type => 'WebVoter'}

  scope :has_email, :conditions => "length(email) > 0"

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
