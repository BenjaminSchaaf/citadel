require 'rails_helper'

describe 'teams/show' do
  let(:team) { build_stubbed(:team) }
  let(:invite) { build_stubbed(:team_invite) }
  let(:players) { build_stubbed_list(:team_player, 6) }
  let(:transfers_in) { build_stubbed_list(:team_transfer, 5, team: team, is_joining: true) }
  let(:transfers_out) { build_stubbed_list(:team_transfer, 5, team: team, is_joining: false) }
  let(:active_league) { build_stubbed(:league) }
  let(:signup_league) { build_stubbed(:league, signuppable: true) }
  let(:completed_league) { build_stubbed(:league, status: :completed) }

  before do
    @active_rosters = [active_league, signup_league].map do |league|
      division = build_stubbed(:league_division, league: league)
      build_stubbed(:league_roster, division: division)
    end
    @active_rosters << build_stubbed(:league_roster, disbanded: true)

    past_div = build_stubbed(:league_division, league: completed_league)
    @past_rosters = [
      build_stubbed(:league_roster, division: past_div),
      build_stubbed(:league_roster, division: past_div, disbanded: true),
    ]

    roster = @active_rosters.first
    @matches = []
    @matches << build_stubbed(:league_match, home_team: roster, status: 'confirmed')
    @matches << build_stubbed(:league_match, home_team: roster, status: 'pending',
                                             round_name: 'Finals', scheduled_at: Time.zone.now)
    @matches << build_stubbed(:bye_league_match, home_team: roster, status: 'confirmed')
    League::Match.forfeit_bies.each_key do |ff|
      @matches << build_stubbed(:league_match, home_team: roster, forfeit_by: ff,
                                               status: 'confirmed')
    end

    match = @matches.first
    rounds = []
    rounds << build_stubbed(:league_match_round, match: match, home_team_score: 2,
                                                 away_team_score: 1)
    rounds << build_stubbed(:league_match_round, match: match, home_team_score: 1,
                                                 away_team_score: 2)
    rounds << build_stubbed(:league_match_round, match: match, home_team_score: 3,
                                                 away_team_score: 3)
    @matches.each do |match_|
      allow(match_).to receive(:rounds).and_return(rounds)
    end

    roster_users = (@active_rosters + @past_rosters).map(&:players).reduce([], :+)
    @users = (players + transfers_in + transfers_out + roster_users).map(&:user).index_by(&:id)

    @active_roster_matches = {
      @active_rosters[0] => @matches,
      @active_rosters[2] => @matches,
    }

    @past_roster_matches = {
      @past_rosters[1] => @matches,
    }

    assign(:team, team)
    assign(:invite, invite)
    assign(:players, players)
    assign(:transfers, transfers_in + transfers_out)
    assign(:active_rosters, @active_rosters)
    assign(:active_roster_matches, @active_roster_matches)
    assign(:past_rosters, @past_rosters)
    assign(:past_roster_matches, @past_roster_matches)
    assign(:upcoming_matches, @matches)
    assign(:users, @users)
  end

  it 'shows public team data' do
    render

    expect(rendered).to include(team.name)

    players.each do |player|
      expect(rendered).to include(player.user.name)
    end

    transfers_in.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    transfers_out.each do |transfer|
      expect(rendered).to include(transfer.user.name)
    end

    (@active_rosters + @past_rosters).each do |roster|
      expect(rendered).to include(roster.name)

      roster.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end

    @matches.each do |match|
      expect(rendered).to include(match.home_team.name)
      expect(rendered).to include(match.away_team.name) if match.away_team
      expect(rendered).to include(match.scheduled_at.strftime('%c')) if match.scheduled_at
    end

    @users.each_value do |user|
      expect(rendered).to include(user.name)
    end
  end

  it 'shows for captain' do
    # Fake login
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(players[0].user)
    # Fake captain
    allow(view).to receive(:user_can_edit_team?).and_return(true)

    render
  end

  it 'shows for league admin' do
    # Fake login
    allow(view).to receive(:user_signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(build(:user))
    # Fake admin
    allow(view).to receive(:user_can_edit_teams?).and_return(true)

    render
  end
end
