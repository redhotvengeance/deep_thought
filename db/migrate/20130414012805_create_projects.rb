class CreateProjects < ActiveRecord::Migration
  def up
    create_table :projects do |t|
      t.string :name
      t.string :repo_url
      t.string :deploy_type

      t.timestamps
    end
  end

  def down
    drop_table :projects
  end
end
