class CreateRepositories < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name
      t.string :url
      t.string :owner_login
    end
  end

  def self.down
    drop_table :repositories
  end
end
