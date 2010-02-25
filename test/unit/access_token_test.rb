require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
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

