require 'rails_helper'

describe 'leagues/matches/index' do
  let(:div) { build_stubbed(:league_division) }
  let(:home_team) { build_stubbed(:league_roster) }
  let(:away_team) { build_stubbed(:league_roster) }

  before do
    @matches = []
    @matches << build_stubbed(:league_match, home_team: home_team,
                                             away_team: away_team, status: 'confirmed',
                                             scheduled_at: Time.zone.now)
    @matches << build_stubbed(:league_match, home_team: home_team, away_team: away_team,
                                             status: 'pending', round_name: 'Finals')
    @matches << build_stubbed(:bye_league_match, home_team: home_team, status: 'confirmed')
    League::Match.forfeit_bies.each_key do |ff|
      @matches << build_stubbed(:league_match, home_team: home_team, away_team: away_team,
                                               forfeit_by: ff, status: 'confirmed')
    end

    rounds = []
    rounds << build_stubbed(:league_match_round, home_team_score: 2, away_team_score: 1)
    rounds << build_stubbed(:league_match_round, home_team_score: 1, away_team_score: 2)
    rounds << build_stubbed(:league_match_round, home_team_score: 3, away_team_score: 3)
    @matches.each do |match|
      allow(match).to receive(:rounds).and_return(rounds)
    end
  end

  it 'displays matches', :aggregate_failures do
    allow(view).to receive(:user_can_edit_league?).and_return(true)
    assign(:league, div.league)
    assign(:divisions, [div])
    assign(:matches, div => @matches)

    render

    @matches.each do |match|
      expect(rendered).to include(match.home_team.name)
      expect(rendered).to include(match.away_team.name) if match.away_team
      expect(rendered).to include(match.scheduled_at.strftime('%c')) if match.scheduled_at
    end
  end
end
