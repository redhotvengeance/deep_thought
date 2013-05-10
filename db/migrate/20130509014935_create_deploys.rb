class CreateDeploys < ActiveRecord::Migration
  def up
    create_table :deploys do |t|
      t.text :actions
      t.string :branch
      t.string :environment
      t.string :box
      t.text :variables
      t.string :commit
      t.datetime :started_at
      t.datetime :finished_at
      t.boolean :in_progress, :default => false
      t.boolean :was_successful
      t.text :log
      t.string :via
      t.string :on_behalf_of
      t.references :project
      t.references :user

      t.timestamps
    end
  end

  def down
    drop_table :deploys
  end
end
