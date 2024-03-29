class AddAttributesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :nick, :string
  end

  def self.down
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :nick, :string
  end
end
