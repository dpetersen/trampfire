class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :clone_url
      t.string :heroku_app_name
    end
  end

  def self.down
    drop_table :projects
  end
end
