class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :user
      t.text :caption
      t.string :thumbnail
      t.string :image
      t.references :event

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
