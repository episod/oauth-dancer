class ServiceProviderWithXauth < ActiveRecord::Migration
  def self.up
    add_column :service_providers, :use_xauth, :boolean, :default => false
  end

  def self.down
    remove_column :service_providers, :use_xauth
  end
end
