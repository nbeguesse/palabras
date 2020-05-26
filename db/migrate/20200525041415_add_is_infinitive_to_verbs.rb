class AddIsInfinitiveToVerbs < ActiveRecord::Migration
  def change
    add_column :verbs, :is_infinitive, :boolean, :default=>false
    add_column :verbs, :is_participle, :boolean, :default=>false
  end
end
