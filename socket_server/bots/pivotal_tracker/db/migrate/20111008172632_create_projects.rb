class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :project_id
      t.string :destination_tag_name
    end
  end

  def self.down
    drop_table :projects
  end
end
