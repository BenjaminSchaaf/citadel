class CreateLeagueMatchScheduleEdits < ActiveRecord::Migration[5.2]
  def change
    add_column :leagues, :allow_rescheduling, :boolean, null: false, default: false
    change_column_default :leagues, :allow_rescheduling, from: false, to: true

    create_table :league_match_schedule_edits do |t|
      t.integer :match_id, null: false, index: true
      t.integer :created_by_id, null: false, index: true
      t.integer :decided_by_id, index: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false, index: true
      t.datetime :scheduled_at, null: false
      t.integer :deciding_team, null: false, limit: 1
      t.boolean :approved
    end

    add_foreign_key :league_match_schedule_edits, :league_matches, column: :match_id
    add_foreign_key :league_match_schedule_edits, :users, column: :created_by_id
    add_foreign_key :league_match_schedule_edits, :users, column: :decided_by_id
  end
end
