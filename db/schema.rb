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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140902233127) do

  create_table "friendships", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.integer  "friend_id"
    t.string   "email"
    t.string   "username"
  end

  create_table "games", :force => true do |t|
    t.string   "result"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "game_type"
    t.integer  "player_1_id"
    t.integer  "player_2_id"
    t.integer  "difficulty"
    t.integer  "board_size"
  end

  create_table "moves", :force => true do |t|
    t.integer  "square"
    t.integer  "game_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "player_number"
    t.integer  "current_user"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "role"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "username"
  end

end
