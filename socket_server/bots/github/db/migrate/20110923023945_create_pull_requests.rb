class CreatePullRequests < ActiveRecord::Migration
  def self.up
    create_table :pull_requests do |t|
      t.string :owner_login
      t.string :repository_name
      t.integer :pull_request_number
    end
  end

  def self.down
    drop_table :pull_requests
  end
end
