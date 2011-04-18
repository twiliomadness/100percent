class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :phone_number

  # TODO: Add :token_authenticatable, then re-enable this:
  # before_save :reset_authentication_token

  has_many :voters
  has_one :sms_voter, :conditions => {:type => 'SmsVoter'} 
  has_one :voice_voter, :conditions => {:type => 'VoiceVoter'} 
  
  scope :has_email, :conditions => "length(email) > 0"

  def self.default_attributes(attrs = {})
    {:first_name => "John", 
      :email => "junk@votesimple.org",
      :password => "iamnotapotato",
      :last_name => "Smith"}.merge(attrs)
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    if user = User.find_by_email(data["email"])
      user
    else # Create a user with a stub password. 
      User.create!(:email => data["email"], :password => Devise.friendly_token[0,20]) 
    end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
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

end
