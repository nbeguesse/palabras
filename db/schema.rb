# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200527061028) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "infinitives", force: :cascade do |t|
    t.string   "name"
    t.string   "meaning"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "infinitives", ["name"], name: "index_infinitives_on_name", using: :btree

  create_table "verbs", force: :cascade do |t|
    t.string   "word"
    t.integer  "infinitive_id"
    t.integer  "pronoun"
    t.integer  "mood"
    t.integer  "tense"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "is_infinitive",        default: false
    t.boolean  "is_participle",        default: false
    t.string   "word_no_accents"
    t.string   "previous_word_is"
    t.string   "previous_word_is_not"
  end

  add_index "verbs", ["word"], name: "index_verbs_on_word", using: :btree

end
