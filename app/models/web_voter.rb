class WebVoter < Voter
  after_save :update_voter_information
  accepts_nested_attributes_for :user

  validate :validate_user_email_present
  
  private

  def update_voter_information
    # TODO: Contextual updates?  Or all the time on save?
    self.update_voting_information
  end

  def validate_user_email_present
    if user && !user.email.present?
      errors.add(:base, "Email is required")
    end
  end

end
