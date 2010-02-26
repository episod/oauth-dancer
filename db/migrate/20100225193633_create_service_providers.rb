class CreateServiceProviders < ActiveRecord::Migration
  def self.up
    create_table :service_providers do |t|
      t.string :label
      t.text :note
      t.string :consumer_key
      t.string :consumer_secret
      t.string :request_token_url
      t.string :authorize_url
      t.string :access_token_url
      t.string :oauth_version, :default => "1.0"
      t.string :default_response_content_type, :default => "application/x-www-form-urlencoded; charset=utf-8"
      t.string :default_request_content_type, :default => "application/x-www-form-urlencoded; charset=utf-8"
      t.string :oauth_scheme, :default => "header"
      t.boolean :use_out_of_band, :default => false 
      t.boolean :use_post_for_authentication_steps, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :service_providers
  end
end
