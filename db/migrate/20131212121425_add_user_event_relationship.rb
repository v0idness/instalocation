class AddUserEventRelationship < ActiveRecord::Migration
  def self.up
  end

  def self.down
  end

  def change
  	add_index :events, :user_id
  end
end
