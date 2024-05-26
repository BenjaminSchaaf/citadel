class AddScheduledAtToLeagueMatches < ActiveRecord::Migration[5.2]
  def change
    add_column :league_matches, :scheduled_at, :datetime
  end
end
