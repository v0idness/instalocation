class AddLinkToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :link, :string
  end

  def self.down
    remove_column :photos, :link
  end
end
