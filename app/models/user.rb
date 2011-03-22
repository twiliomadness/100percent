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


  has_many :voters
  has_one :sms_voter, :conditions => {:type => 'SmsVoter'} 
  has_one :voice_voter, :conditions => {:type => 'VoiceVoter'} 

  def self.default_attributes(attrs = {})
    {:first_name => "John",
      :last_name => "Smith"}.merge(attrs)
  end


end
