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
      t.boolean :use_out_of_band

      t.timestamps
    end
  end

  def self.down
    drop_table :service_providers
  end
end
