class CreateAccessTokens < ActiveRecord::Migration
  def self.up
    create_table :access_tokens do |t|
      t.string :label
      t.string :oauth_token
      t.string :oauth_token_secret
      t.integer :service_provider_id
      t.timestamps
    end
  end

  def self.down
    drop_table :access_tokens
  end
end
