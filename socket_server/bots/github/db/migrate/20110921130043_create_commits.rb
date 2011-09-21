class CreateCommits < ActiveRecord::Migration
  def self.up
    create_table :commits do |t|
      t.string :sha
      t.string :url
      t.text :message
      t.string :author_login
      t.string :author_email
      t.string :author_name
    end
  end

  def self.down
    drop_table :commits
  end
end
