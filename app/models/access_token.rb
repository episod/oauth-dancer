class AccessToken < ActiveRecord::Base
  belongs_to :service_provider

  def to_oauth_access_token
    consumer = self.service_provider.to_oauth_consumer
    OAuth::AccessToken.from_hash(consumer, { :oauth_token => self.oauth_token, :oauth_token_secret => self.oauth_token_secret})
  end
  
  def to_s(with_service_provider = false)
    string = "#{self.label} (#{self.oauth_token[0..5]})"
    if with_service_provider
      string = "#{self.service_provider.label} - #{string}"
    end
    string
  end
end


# == Schema Information
#
# Table name: access_tokens
#
#  id                  :integer         not null, primary key
#  label               :string(255)
#  oauth_token         :string(255)
#  oauth_token_secret  :string(255)
#  service_provider_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#

