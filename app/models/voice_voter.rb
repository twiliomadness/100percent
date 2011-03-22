class VoiceVoter < Voter
  before_create :assure_single_voice_voter

  def assure_single_voice_voter
    unless user.voice_voter.nil?
      user.voice_voter.update_attribute(:type => nil)
    end
  end


end