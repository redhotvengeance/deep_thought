class AddCiToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :ci, :boolean, :default => true
  end

  def down
    remove_column :projects, :ci
  end
end
