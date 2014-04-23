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

ActiveRecord::Schema.define(version: 20140417223606) do

  create_table "alerts", force: true do |t|
    t.float    "threshold"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "game_id"
  end

  create_table "game_sale_histories", force: true do |t|
    t.datetime "occurred"
    t.integer  "game_id"
    t.string   "store"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_sales", force: true do |t|
    t.integer  "game_id"
    t.datetime "occurrence"
    t.string   "store"
    t.string   "url"
    t.float    "origamt"
    t.float    "saleamt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_user_wrappers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "game_id"
  end

  create_table "games", force: true do |t|
    t.string   "title"
    t.string   "platform"
    t.date     "release_date"
    t.string   "description"
    t.string   "players"
    t.string   "esrb_rating"
    t.string   "coop"
    t.string   "publisher"
    t.string   "developer"
    t.string   "genres"
    t.string   "metacritic_rating"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "search_title"
    t.integer  "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "filter"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
