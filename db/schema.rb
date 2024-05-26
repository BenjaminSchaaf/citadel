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

ActiveRecord::Schema.define(version: 2024_05_22_191744) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "action_user_edit_games", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_games_on_user_id"
  end

  create_table "action_user_edit_league", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
    t.index ["league_id"], name: "index_action_user_edit_league_on_league_id"
    t.index ["user_id"], name: "index_action_user_edit_league_on_user_id"
  end

  create_table "action_user_edit_leagues", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_leagues_on_user_id"
  end

  create_table "action_user_edit_permissions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_permissions_on_user_id"
  end

  create_table "action_user_edit_team", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.index ["team_id"], name: "index_action_user_edit_team_on_team_id"
    t.index ["user_id"], name: "index_action_user_edit_team_on_user_id"
  end

  create_table "action_user_edit_teams", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_teams_on_user_id"
  end

  create_table "action_user_edit_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_edit_users_on_user_id"
  end

  create_table "action_user_manage_forums", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_manage_forums_on_user_id"
  end

  create_table "action_user_manage_forums_thread", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_thread_id"
    t.index ["forums_thread_id"], name: "index_action_user_manage_forums_thread_on_forums_thread_id"
    t.index ["user_id"], name: "index_action_user_manage_forums_thread_on_user_id"
  end

  create_table "action_user_manage_forums_topic", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_topic_id"
    t.index ["forums_topic_id"], name: "index_action_user_manage_forums_topic_on_forums_topic_id"
    t.index ["user_id"], name: "index_action_user_manage_forums_topic_on_user_id"
  end

  create_table "action_user_manage_rosters_league", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
    t.index ["league_id"], name: "index_action_user_manage_rosters_league_on_league_id"
    t.index ["user_id"], name: "index_action_user_manage_rosters_league_on_user_id"
  end

  create_table "action_user_manage_rosters_leagues", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.index ["user_id"], name: "index_action_user_manage_rosters_leagues_on_user_id"
  end

  create_table "action_user_use_forums_bans", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "reason", default: "", null: false
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_action_user_use_forums_bans_on_user_id"
  end

  create_table "action_user_use_forums_thread_bans", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_thread_id"
    t.string "reason", default: "", null: false
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forums_thread_id"], name: "index_action_user_use_forums_thread_bans_on_forums_thread_id"
    t.index ["user_id"], name: "index_action_user_use_forums_thread_bans_on_user_id"
  end

  create_table "action_user_use_forums_topic_bans", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "forums_topic_id"
    t.string "reason", default: "", null: false
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forums_topic_id"], name: "index_action_user_use_forums_topic_bans_on_forums_topic_id"
    t.index ["user_id"], name: "index_action_user_use_forums_topic_bans_on_user_id"
  end

  create_table "action_user_use_leagues_bans", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "reason", default: "", null: false
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_action_user_use_leagues_bans_on_user_id"
  end

  create_table "action_user_use_teams_bans", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "reason", default: "", null: false
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_action_user_use_teams_bans_on_user_id"
  end

  create_table "action_user_use_users_bans", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "reason", default: "", null: false
    t.datetime "terminated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_action_user_use_users_bans_on_user_id"
  end

  create_table "api_keys", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "key", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_api_keys_on_key"
    t.index ["name"], name: "index_api_keys_on_name"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "formats", id: :serial, force: :cascade do |t|
    t.integer "game_id"
    t.string "name", null: false
    t.text "description", null: false
    t.integer "player_count", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description_render_cache", default: "", null: false
    t.index ["game_id"], name: "index_formats_on_game_id"
    t.index ["name"], name: "index_formats_on_name", unique: true
  end

  create_table "forums_post_edits", id: :serial, force: :cascade do |t|
    t.integer "post_id", null: false
    t.integer "created_by_id", null: false
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_render_cache", default: "", null: false
    t.index ["created_by_id"], name: "index_forums_post_edits_on_created_by_id"
    t.index ["post_id"], name: "index_forums_post_edits_on_post_id"
  end

  create_table "forums_posts", id: :serial, force: :cascade do |t|
    t.integer "thread_id", null: false
    t.integer "created_by_id", null: false
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "edits_count", default: 0, null: false
    t.text "content_render_cache", default: "", null: false
    t.index ["created_by_id"], name: "index_forums_posts_on_created_by_id"
    t.index ["thread_id"], name: "index_forums_posts_on_thread_id"
  end

  create_table "forums_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "topic_id"
    t.integer "thread_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["thread_id"], name: "index_forums_subscriptions_on_thread_id"
    t.index ["topic_id"], name: "index_forums_subscriptions_on_topic_id"
    t.index ["user_id"], name: "index_forums_subscriptions_on_user_id"
  end

  create_table "forums_threads", id: :serial, force: :cascade do |t|
    t.integer "topic_id"
    t.integer "created_by_id", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked"
    t.boolean "pinned"
    t.boolean "hidden"
    t.integer "depth", default: 0, null: false
    t.integer "posts_count", default: 0, null: false
    t.index ["created_by_id"], name: "index_forums_threads_on_created_by_id"
    t.index ["topic_id"], name: "index_forums_threads_on_topic_id"
  end

  create_table "forums_topics", id: :serial, force: :cascade do |t|
    t.integer "created_by_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked"
    t.boolean "pinned"
    t.boolean "hidden"
    t.boolean "isolated"
    t.boolean "default_hidden"
    t.integer "ancestry_depth", default: 0, null: false
    t.string "ancestry"
    t.integer "visible_threads_count", default: 0, null: false
    t.boolean "default_locked", default: false
    t.integer "isolated_by_id"
    t.text "description", default: "", null: false
    t.text "description_render_cache", default: "", null: false
    t.index ["ancestry"], name: "index_forums_topics_on_ancestry"
    t.index ["created_by_id"], name: "index_forums_topics_on_created_by_id"
  end

  create_table "games", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_games_on_name", unique: true
  end

  create_table "league_divisions", id: :serial, force: :cascade do |t|
    t.integer "league_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_league_divisions_on_league_id"
  end

  create_table "league_match_comm_edits", id: :serial, force: :cascade do |t|
    t.integer "created_by_id", null: false
    t.integer "comm_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_render_cache", default: "", null: false
    t.index ["comm_id"], name: "index_league_match_comm_edits_on_comm_id"
    t.index ["created_by_id"], name: "index_league_match_comm_edits_on_created_by_id"
  end

  create_table "league_match_comms", id: :serial, force: :cascade do |t|
    t.integer "match_id"
    t.integer "created_by_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_render_cache", default: "", null: false
    t.integer "edits_count", default: 0, null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.index ["created_by_id"], name: "index_league_match_comms_on_created_by_id"
    t.index ["match_id"], name: "index_league_match_comms_on_match_id"
  end

  create_table "league_match_pick_bans", id: :serial, force: :cascade do |t|
    t.integer "match_id", null: false
    t.integer "picked_by_id"
    t.integer "kind", limit: 2, null: false
    t.integer "team", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "map_id"
    t.boolean "deferrable", default: false, null: false
    t.integer "order_number", default: 0
    t.index ["map_id"], name: "index_league_match_pick_bans_on_map_id"
    t.index ["match_id"], name: "index_league_match_pick_bans_on_match_id"
  end

  create_table "league_match_rounds", id: :serial, force: :cascade do |t|
    t.integer "match_id"
    t.integer "map_id"
    t.integer "home_team_score", default: 0, null: false
    t.integer "away_team_score", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "loser_id"
    t.integer "winner_id"
    t.boolean "has_outcome", default: false, null: false
    t.decimal "score_difference", precision: 20, scale: 6, default: "0.0", null: false
    t.index ["loser_id"], name: "index_league_match_rounds_on_loser_id"
    t.index ["map_id"], name: "index_league_match_rounds_on_map_id"
    t.index ["match_id"], name: "index_league_match_rounds_on_match_id"
    t.index ["winner_id"], name: "index_league_match_rounds_on_winner_id"
  end

  create_table "league_matches", id: :serial, force: :cascade do |t|
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "forfeit_by", default: 0, null: false
    t.integer "round_number", default: 1, null: false
    t.string "notice", default: "", null: false
    t.string "round_name", default: "", null: false
    t.text "notice_render_cache", default: "", null: false
    t.boolean "has_winner", default: false, null: false
    t.integer "winner_id"
    t.integer "loser_id"
    t.string "script_state"
    t.decimal "total_score_difference", precision: 20, scale: 6, default: "0.0", null: false
    t.decimal "total_home_team_score", precision: 20, scale: 6, default: "0.0", null: false
    t.decimal "total_away_team_score", precision: 20, scale: 6, default: "0.0", null: false
    t.boolean "allow_round_draws", default: false, null: false
    t.integer "total_home_team_round_wins", default: 0, null: false
    t.integer "total_away_team_round_wins", default: 0, null: false
    t.integer "total_round_draws", default: 0, null: false
    t.datetime "scheduled_at"
    t.index ["away_team_id"], name: "index_league_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_league_matches_on_home_team_id"
    t.index ["loser_id"], name: "index_league_matches_on_loser_id"
    t.index ["winner_id"], name: "index_league_matches_on_winner_id"
  end

  create_table "league_pooled_maps", id: :serial, force: :cascade do |t|
    t.integer "league_id"
    t.integer "map_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_league_pooled_maps_on_league_id"
    t.index ["map_id"], name: "index_league_pooled_maps_on_map_id"
  end

  create_table "league_roster_comment_edits", id: :serial, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "created_by_id", null: false
    t.string "content", null: false
    t.text "content_render_cache", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_league_roster_comment_edits_on_comment_id"
    t.index ["created_by_id"], name: "index_league_roster_comment_edits_on_created_by_id"
  end

  create_table "league_roster_comments", id: :serial, force: :cascade do |t|
    t.integer "roster_id", null: false
    t.integer "created_by_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content_render_cache", default: "", null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.index ["created_by_id"], name: "index_league_roster_comments_on_created_by_id"
    t.index ["roster_id"], name: "index_league_roster_comments_on_roster_id"
  end

  create_table "league_roster_players", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "roster_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["roster_id"], name: "index_league_roster_players_on_roster_id"
    t.index ["user_id"], name: "index_league_roster_players_on_user_id"
  end

  create_table "league_roster_transfer_requests", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "roster_id"
    t.boolean "is_joining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.integer "approved_by_id"
    t.integer "denied_by_id"
    t.integer "leaving_roster_id"
    t.index ["approved_by_id", "denied_by_id"], name: "transfer_requests_on_approved_by_id_and_denied_by_id"
    t.index ["roster_id"], name: "index_league_roster_transfer_requests_on_roster_id"
    t.index ["user_id"], name: "index_league_roster_transfer_requests_on_user_id"
  end

  create_table "league_roster_transfers", id: :serial, force: :cascade do |t|
    t.integer "roster_id", null: false
    t.integer "user_id", null: false
    t.boolean "is_joining", null: false
    t.boolean "approved", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["roster_id"], name: "index_league_roster_transfers_on_roster_id"
    t.index ["user_id"], name: "index_league_roster_transfers_on_user_id"
  end

  create_table "league_rosters", id: :serial, force: :cascade do |t|
    t.integer "team_id", null: false
    t.integer "division_id", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.boolean "disbanded", default: false, null: false
    t.integer "ranking"
    t.integer "seeding"
    t.integer "won_rounds_count", default: 0, null: false
    t.integer "drawn_rounds_count", default: 0, null: false
    t.integer "lost_rounds_count", default: 0, null: false
    t.integer "won_matches_count", default: 0, null: false
    t.integer "lost_matches_count", default: 0, null: false
    t.decimal "points", default: "0.0", null: false
    t.decimal "total_scores", default: "0.0", null: false
    t.json "schedule_data"
    t.integer "won_rounds_against_tied_rosters_count", default: 0, null: false
    t.text "description_render_cache", default: "", null: false
    t.integer "drawn_matches_count", default: 0, null: false
    t.integer "forfeit_won_matches_count", default: 0, null: false
    t.integer "forfeit_drawn_matches_count", default: 0, null: false
    t.integer "forfeit_lost_matches_count", default: 0, null: false
    t.text "notice", default: "", null: false
    t.text "notice_render_cache", default: "", null: false
    t.decimal "total_score_difference", precision: 20, scale: 6, default: "0.0", null: false
    t.integer "placement"
    t.integer "bye_matches_count", default: 0, null: false
    t.decimal "normalized_round_score", default: "0.0", null: false
    t.decimal "buchholz_score", default: "0.0", null: false
    t.decimal "median_buchholz_score", default: "0.0", null: false
    t.index ["division_id"], name: "index_league_rosters_on_division_id"
    t.index ["points"], name: "index_league_rosters_on_points"
    t.index ["team_id"], name: "index_league_rosters_on_team_id"
  end

  create_table "league_schedulers_weeklies", id: :serial, force: :cascade do |t|
    t.integer "league_id", null: false
    t.integer "start_of_week", null: false
    t.boolean "days", default: [true, true, true, true, true, true, true], null: false, array: true
    t.integer "minimum_selected", default: 0, null: false
    t.index ["league_id"], name: "index_league_schedulers_weeklies_on_league_id"
  end

  create_table "league_tiebreakers", id: :serial, force: :cascade do |t|
    t.integer "league_id"
    t.integer "kind", null: false
    t.index ["league_id"], name: "index_league_tiebreakers_on_league_id"
  end

  create_table "leagues", id: :serial, force: :cascade do |t|
    t.integer "format_id"
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "signuppable", default: false, null: false
    t.boolean "roster_locked", default: false, null: false
    t.integer "min_players", default: 6, null: false
    t.integer "max_players", default: 0, null: false
    t.boolean "matches_submittable", default: false, null: false
    t.boolean "transfers_require_approval", default: true, null: false
    t.decimal "points_per_round_win", default: "2.0", null: false
    t.decimal "points_per_round_draw", default: "1.0", null: false
    t.decimal "points_per_round_loss", default: "0.0", null: false
    t.decimal "points_per_match_loss", default: "0.0", null: false
    t.decimal "points_per_match_win", default: "1.0", null: false
    t.boolean "allow_disbanding", default: false, null: false
    t.integer "status", default: 0, null: false
    t.integer "rosters_count", default: 0, null: false
    t.integer "schedule", default: 0, null: false
    t.boolean "schedule_locked", default: false, null: false
    t.string "query_name_cache", default: "", null: false
    t.text "description_render_cache", default: "", null: false
    t.decimal "points_per_match_draw", default: "0.0", null: false
    t.string "category", default: "", null: false
    t.decimal "points_per_forfeit_win", default: "2.0", null: false
    t.decimal "points_per_forfeit_draw", default: "1.0", null: false
    t.decimal "points_per_forfeit_loss", default: "0.0", null: false
    t.boolean "forfeit_all_matches_when_roster_disbands", default: true, null: false
    t.boolean "hide_rosters", default: false, null: false
    t.index ["format_id"], name: "index_leagues_on_format_id"
    t.index ["query_name_cache"], name: "index_leagues_on_query_name_change", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "maps", id: :serial, force: :cascade do |t|
    t.integer "game_id"
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description_render_cache", default: "", null: false
    t.index ["game_id"], name: "index_maps_on_game_id"
  end

  create_table "team_invites", id: :serial, force: :cascade do |t|
    t.integer "team_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_invites_on_team_id"
    t.index ["user_id"], name: "index_team_invites_on_user_id"
  end

  create_table "team_players", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_players_on_team_id"
    t.index ["user_id"], name: "index_team_players_on_user_id"
  end

  create_table "team_transfers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.boolean "is_joining", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_transfers_on_team_id"
    t.index ["user_id"], name: "index_team_transfers_on_user_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.integer "players_count", default: 0, null: false
    t.string "query_name_cache", default: "", null: false
    t.text "description_render_cache", default: "", null: false
    t.text "notice", default: "", null: false
    t.text "notice_render_cache", default: "", null: false
    t.string "avatar_token"
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["query_name_cache"], name: "index_teams_on_query_name_cache", opclass: :gist_trgm_ops, using: :gist
  end

  create_table "user_comment_edits", id: :serial, force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "created_by_id", null: false
    t.string "content", null: false
    t.text "content_render_cache", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_user_comment_edits_on_comment_id"
    t.index ["created_by_id"], name: "index_user_comment_edits_on_created_by_id"
  end

  create_table "user_comments", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "created_by_id", null: false
    t.text "content", null: false
    t.text "content_render_cache", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "deleted_by_id"
    t.index ["user_id"], name: "index_user_comments_on_user_id"
  end

  create_table "user_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.inet "ip", null: false
    t.datetime "first_seen_at", null: false
    t.datetime "last_seen_at", null: false
    t.index ["ip"], name: "index_user_logs_on_ip"
    t.index ["user_id", "ip"], name: "index_user_logs_on_user_id_and_ip", unique: true
    t.index ["user_id"], name: "index_user_logs_on_user_id"
  end

  create_table "user_name_changes", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "approved_by_id"
    t.integer "denied_by_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_user_name_changes_on_approved_by_id"
    t.index ["denied_by_id"], name: "index_user_name_changes_on_denied_by_id"
    t.index ["user_id"], name: "index_user_name_changes_on_user_id"
  end

  create_table "user_notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "read", default: false, null: false
    t.string "message", null: false
    t.string "link", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_titles", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "league_id"
    t.integer "roster_id"
    t.string "name", null: false
    t.string "badge"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["league_id"], name: "index_user_titles_on_league_id"
    t.index ["roster_id"], name: "index_user_titles_on_roster_id"
    t.index ["user_id"], name: "index_user_titles_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.bigint "steam_id", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description", default: "", null: false
    t.string "remember_token"
    t.string "avatar"
    t.string "email"
    t.datetime "confirmed_at"
    t.string "confirmation_token"
    t.datetime "confirmation_sent_at"
    t.string "query_name_cache", default: "", null: false
    t.text "description_render_cache", default: "", null: false
    t.string "badge_name", default: "", null: false
    t.integer "badge_color", default: 0, null: false
    t.text "notice", default: "", null: false
    t.text "notice_render_cache", default: "", null: false
    t.string "avatar_token"
    t.integer "forums_posts_count", default: 0, null: false
    t.integer "public_forums_posts_count", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["query_name_cache"], name: "index_users_on_query_name_cache", opclass: :gist_trgm_ops, using: :gist
    t.index ["steam_id"], name: "index_users_on_steam_id", unique: true
  end

  add_foreign_key "action_user_edit_games", "users"
  add_foreign_key "action_user_edit_league", "leagues"
  add_foreign_key "action_user_edit_league", "users"
  add_foreign_key "action_user_edit_leagues", "users"
  add_foreign_key "action_user_edit_permissions", "users"
  add_foreign_key "action_user_edit_team", "teams"
  add_foreign_key "action_user_edit_team", "users"
  add_foreign_key "action_user_edit_teams", "users"
  add_foreign_key "action_user_edit_users", "users"
  add_foreign_key "action_user_manage_forums", "users"
  add_foreign_key "action_user_manage_forums_thread", "forums_threads"
  add_foreign_key "action_user_manage_forums_thread", "users"
  add_foreign_key "action_user_manage_forums_topic", "forums_topics"
  add_foreign_key "action_user_manage_forums_topic", "users"
  add_foreign_key "action_user_manage_rosters_league", "leagues"
  add_foreign_key "action_user_manage_rosters_league", "users"
  add_foreign_key "action_user_manage_rosters_leagues", "users"
  add_foreign_key "action_user_use_forums_bans", "users"
  add_foreign_key "action_user_use_forums_thread_bans", "forums_threads"
  add_foreign_key "action_user_use_forums_thread_bans", "users"
  add_foreign_key "action_user_use_forums_topic_bans", "forums_topics"
  add_foreign_key "action_user_use_forums_topic_bans", "users"
  add_foreign_key "action_user_use_leagues_bans", "users"
  add_foreign_key "action_user_use_teams_bans", "users"
  add_foreign_key "action_user_use_users_bans", "users"
  add_foreign_key "formats", "games"
  add_foreign_key "forums_post_edits", "forums_posts", column: "post_id"
  add_foreign_key "forums_post_edits", "users", column: "created_by_id"
  add_foreign_key "forums_posts", "forums_threads", column: "thread_id"
  add_foreign_key "forums_posts", "users", column: "created_by_id"
  add_foreign_key "forums_subscriptions", "forums_threads", column: "thread_id"
  add_foreign_key "forums_subscriptions", "forums_topics", column: "topic_id"
  add_foreign_key "forums_subscriptions", "users"
  add_foreign_key "forums_threads", "forums_topics", column: "topic_id"
  add_foreign_key "forums_threads", "users", column: "created_by_id"
  add_foreign_key "forums_topics", "forums_topics", column: "isolated_by_id"
  add_foreign_key "forums_topics", "users", column: "created_by_id"
  add_foreign_key "league_divisions", "leagues"
  add_foreign_key "league_match_comm_edits", "league_match_comms", column: "comm_id"
  add_foreign_key "league_match_comm_edits", "users", column: "created_by_id"
  add_foreign_key "league_match_comms", "league_matches", column: "match_id"
  add_foreign_key "league_match_comms", "users", column: "created_by_id"
  add_foreign_key "league_match_comms", "users", column: "deleted_by_id"
  add_foreign_key "league_match_pick_bans", "league_matches", column: "match_id"
  add_foreign_key "league_match_pick_bans", "maps"
  add_foreign_key "league_match_pick_bans", "users", column: "picked_by_id"
  add_foreign_key "league_match_rounds", "league_matches", column: "match_id"
  add_foreign_key "league_match_rounds", "league_rosters", column: "loser_id"
  add_foreign_key "league_match_rounds", "league_rosters", column: "winner_id"
  add_foreign_key "league_match_rounds", "maps"
  add_foreign_key "league_matches", "league_rosters", column: "away_team_id"
  add_foreign_key "league_matches", "league_rosters", column: "home_team_id"
  add_foreign_key "league_matches", "league_rosters", column: "loser_id"
  add_foreign_key "league_matches", "league_rosters", column: "winner_id"
  add_foreign_key "league_pooled_maps", "leagues"
  add_foreign_key "league_pooled_maps", "maps"
  add_foreign_key "league_roster_comment_edits", "league_roster_comments", column: "comment_id"
  add_foreign_key "league_roster_comment_edits", "users", column: "created_by_id"
  add_foreign_key "league_roster_comments", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_comments", "users", column: "created_by_id"
  add_foreign_key "league_roster_comments", "users", column: "deleted_by_id"
  add_foreign_key "league_roster_players", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_players", "users"
  add_foreign_key "league_roster_transfer_requests", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_transfer_requests", "users"
  add_foreign_key "league_roster_transfer_requests", "users", column: "approved_by_id"
  add_foreign_key "league_roster_transfer_requests", "users", column: "created_by_id"
  add_foreign_key "league_roster_transfer_requests", "users", column: "denied_by_id"
  add_foreign_key "league_roster_transfers", "league_rosters", column: "roster_id"
  add_foreign_key "league_roster_transfers", "users"
  add_foreign_key "league_rosters", "league_divisions", column: "division_id"
  add_foreign_key "league_rosters", "teams"
  add_foreign_key "league_schedulers_weeklies", "leagues"
  add_foreign_key "league_tiebreakers", "leagues"
  add_foreign_key "leagues", "formats"
  add_foreign_key "maps", "games"
  add_foreign_key "team_invites", "teams"
  add_foreign_key "team_invites", "users"
  add_foreign_key "team_players", "teams"
  add_foreign_key "team_players", "users"
  add_foreign_key "team_transfers", "teams"
  add_foreign_key "team_transfers", "users"
  add_foreign_key "user_comment_edits", "user_comments", column: "comment_id"
  add_foreign_key "user_comment_edits", "users", column: "created_by_id"
  add_foreign_key "user_comments", "users"
  add_foreign_key "user_comments", "users", column: "created_by_id"
  add_foreign_key "user_comments", "users", column: "deleted_by_id"
  add_foreign_key "user_logs", "users"
  add_foreign_key "user_name_changes", "users"
  add_foreign_key "user_name_changes", "users", column: "approved_by_id"
  add_foreign_key "user_name_changes", "users", column: "denied_by_id"
  add_foreign_key "user_notifications", "users"
  add_foreign_key "user_titles", "league_rosters", column: "roster_id"
  add_foreign_key "user_titles", "leagues"
  add_foreign_key "user_titles", "users"
end
