class AddServerNameAndApp < ActiveRecord::Migration
  def self.up
    add_column :preferences, :server_name, :string
    add_column :preferences, :app_name, :string
    Preference.create!(:app_name => 'M5', :domain => 'example.com', 
                         :smtp_server => 'mail.example.com', 
                         :email_notifications => false)
  end

  def self.down
    remove_column :preferences, :app_name
    remove_column :preferences, :server_name
  end
end
