require 'test_helper'

class ServiceProviderTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end

# == Schema Information
#
# Table name: service_providers
#
#  id                :integer         not null, primary key
#  label             :string(255)
#  note              :text
#  consumer_key      :string(255)
#  consumer_secret   :string(255)
#  request_token_url :string(255)
#  authorize_url     :string(255)
#  access_token_url  :string(255)
#  use_out_of_band   :boolean
#  created_at        :datetime
#  updated_at        :datetime
#

