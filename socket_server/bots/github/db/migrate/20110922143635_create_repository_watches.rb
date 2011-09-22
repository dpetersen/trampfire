class CreateRepositoryWatches < ActiveRecord::Migration
  def self.up
    create_table :repository_watches do |t|
      t.string :owner_login
      t.string :repository_name
      t.string :destination_tag_name
    end
  end

  def self.down
    drop_table :repository_watches
  end
end
