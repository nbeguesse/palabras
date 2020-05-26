class CreateVerbs < ActiveRecord::Migration
  def change
    create_table :verbs do |t|
      t.string :word
      t.integer :infinitive_id
      t.integer :pronoun
      t.integer :mood
      t.integer :tense

      t.timestamps null: false
    end
    add_index :verbs, [:word]
    add_index :infinitives, [:name]
  end
end
