class CreateInfinitives < ActiveRecord::Migration
  def change
    create_table :infinitives do |t|
      t.string :name
      t.string :meaning
      t.string :link

      t.timestamps null: false
    end
  end
end
