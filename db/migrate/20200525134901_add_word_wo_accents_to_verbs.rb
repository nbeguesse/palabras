class AddWordWoAccentsToVerbs < ActiveRecord::Migration
  def change
    add_column :verbs, :word_no_accents, :string
  end
end
