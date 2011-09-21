class AddBotToMessage < ActiveRecord::Migration
  def self.up
    add_column :messages, :bot, :string
  end

  def self.down
    remove_column :messages, :bot
  end
end
