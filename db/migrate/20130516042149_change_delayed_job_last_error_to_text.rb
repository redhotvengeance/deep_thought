class ChangeDelayedJobLastErrorToText < ActiveRecord::Migration
  def up
    change_column :delayed_jobs, :last_error, :text
  end

  def down
    change_column :delayed_jobs, :last_error, :string
  end
end
