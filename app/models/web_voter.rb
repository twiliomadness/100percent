class WebVoter < Voter
  accepts_nested_attributes_for :user

  validate :validate_user_email_present
  
  private

  def validate_user_email_present
    if user && !user.email.present?
      errors.add(:base, "Email is required")
    end
  end

end
