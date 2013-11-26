class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.integer :location_id
      t.text :text
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
