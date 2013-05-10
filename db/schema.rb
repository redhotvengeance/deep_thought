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

ActiveRecord::Schema.define(:version => 20130509014935) do

  create_table "deploys", :force => true do |t|
    t.text     "actions"
    t.string   "branch"
    t.string   "environment"
    t.string   "box"
    t.text     "variables"
    t.string   "commit"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.boolean  "in_progress",    :default => false
    t.boolean  "was_successful"
    t.text     "log"
    t.string   "via"
    t.string   "on_behalf_of"
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "repo_url"
    t.string   "deploy_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "state"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "api_key"
  end

end
