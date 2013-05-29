class AddNotificationUrlToUsers < ActiveRecord::Migration
  def up
    add_column :users, :notification_url, :string
  end

  def down
    remove_column :users, :notification_url
  end
end
