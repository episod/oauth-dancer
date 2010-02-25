class ServiceProvider < ActiveRecord::Base
  has_many :access_tokens, :class_name => "access_token", :foreign_key => "reference_id", :dependent => :destroy
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

