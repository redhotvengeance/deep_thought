class RemoveDeployTypeAndCiFromProjects < ActiveRecord::Migration
  def up
    remove_column :projects, :ci
    remove_column :projects, :deploy_type
  end

  def down
    add_column :projects, :ci, :string
    add_column :projects, :deploy_type, :string
  end
end
