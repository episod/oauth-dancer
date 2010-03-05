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
#  id                                :integer         not null, primary key
#  label                             :string(255)
#  note                              :text
#  consumer_key                      :string(255)
#  consumer_secret                   :string(255)
#  request_token_url                 :string(255)
#  authorize_url                     :string(255)
#  access_token_url                  :string(255)
#  oauth_version                     :string(255)     default("1.0")
#  default_response_content_type     :string(255)     default("application/x-www-form-urlencoded; charset=utf-8")
#  default_request_content_type      :string(255)     default("application/x-www-form-urlencoded; charset=utf-8")
#  oauth_scheme                      :string(255)     default("header")
#  use_out_of_band                   :boolean         default(FALSE)
#  use_post_for_authentication_steps :boolean         default(TRUE)
#  created_at                        :datetime
#  updated_at                        :datetime
#  use_xauth                         :boolean         default(FALSE)
#

