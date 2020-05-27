class AddPreviousWordEqualsToVerb < ActiveRecord::Migration
  def change
    add_column :verbs, :previous_word_is, :string
    add_column :verbs, :previous_word_is_not, :string
  end
end
