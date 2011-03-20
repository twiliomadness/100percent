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


  # TODO: help, quit, reset, back, other verbs?

  has_many :voters
  has_one :sms_voter, :conditions => {:type => 'sms_voter'} 

  def self.default_attributes(attrs = {})
    {:first_name => "John",
      :last_name => "Smith",
      :phone_number => "+15555551111",
      :date_of_birth => 20.years.ago}.merge(attrs)
  end


end
