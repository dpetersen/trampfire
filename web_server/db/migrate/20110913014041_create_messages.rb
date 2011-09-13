class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.text :original_message
      t.text :final_message
      t.integer :user_id
      t.integer :tag_id
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :messages
  end
end
