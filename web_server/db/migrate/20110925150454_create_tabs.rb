class CreateTabs < ActiveRecord::Migration
  def self.up
    create_table :tabs do |t|
      t.string :name
      t.integer :user_id
    end

    create_table :tag_assignments do |t|
      t.integer :tab_id
      t.integer :tag_id
    end
  end

  def self.down
    drop_table :tabs
    drop_table :tag_assignments
  end
end
