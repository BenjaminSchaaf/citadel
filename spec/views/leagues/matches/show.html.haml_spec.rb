require 'rails_helper'

describe 'leagues/matches/show' do
  let(:user) { build_stubbed(:user) }
  let(:map) { build_stubbed(:map) }
  let(:league) { build_stubbed(:league) }
  let(:division) { build(:league_division, league: league) }
  let(:home_team) { build_stubbed(:league_roster, player_count: 3, division: division) }
  let(:away_team) { build_stubbed(:league_roster, player_count: 3, division: division) }
  let(:match) { build_stubbed(:league_match, home_team: home_team, away_team: away_team, notice: 'Foo') }
  let(:round1) do
    build_stubbed(:league_match_round, home_team_score: 3, away_team_score: 2,
                                       match: match, map: map)
  end
  let(:round2) do
    build_stubbed(:league_match_round, home_team_score: 2, away_team_score: 3,
                                       match: match, map: map)
  end
  let(:round3) do
    build_stubbed(:league_match_round, home_team_score: 1, away_team_score: 1,
                                       match: match, map: map)
  end
  let(:rounds) { [round1, round2, round3] }
  let(:comms) do
    build_stubbed_list(:league_match_comm, 3) +
      build_stubbed_list(:league_match_comm, 3, deleted_by: user)
  end

  before do
    assign(:league, league)
    assign(:match, match)
    assign(:pick_bans, [])
    assign(:rounds, rounds)
    assign(:comm, League::Match::Comm.new(match: match))
    assign(:comms, comms)

    (home_team.users + away_team.users + comms.map(&:created_by)).each do |user|
      allow(user).to receive(:can?).and_return(true)
    end
  end

  context 'home team has more players' do
    before do
      3.times do
        home_team.players << build_stubbed(:league_roster_player, roster: home_team)
      end
    end

    it 'displays all players' do
      render

      home_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
      away_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end
  end

  context 'away team has more players' do
    before do
      3.times do
        away_team.players << build_stubbed(:league_roster_player, roster: away_team)
      end
    end

    it 'displays all players' do
      render

      home_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
      away_team.users.each do |user|
        expect(rendered).to include(user.name)
      end
    end
  end

  shared_examples 'displays matches' do
    it 'displays for captains' do
      allow(view).to receive(:user_can_either_teams?).and_return(true)
      allow(view).to receive(:user_can_edit_league?).and_return(false)

      render
    end

    it 'displays for admins' do
      allow(view).to receive(:user_can_either_teams?).and_return(true)
      allow(view).to receive(:user_can_edit_league?).and_return(true)

      render
    end

    it 'displays for any user' do
      allow(view).to receive(:user_can_either_teams?).and_return(false)
      allow(view).to receive(:user_can_edit_league?).and_return(false)

      render
    end
  end

  context 'BYE match' do
    before do
      match.away_team = nil
      match.status = :confirmed
    end

    it 'displays' do
      render
    end
  end

  context 'standard match' do
    include_examples 'displays matches'

    after do
      comms.each do |comm|
        if view.user_can_edit_league?
          expect(rendered).to include(comm.created_by.name)
        elsif comm.exists?
          expect(rendered).to include(comm.created_by.name)
        else
          expect(rendered).to_not include(comm.created_by.name)
        end
      end
    end
  end

  context 'submitted' do
    before do
      match.status = :submitted_by_home_team
    end

    include_examples 'displays matches'
  end

  context 'confirmed' do
    before do
      match.status = :confirmed
    end

    include_examples 'displays matches'

    context 'home team forfeit' do
      before { match.forfeit_by = :home_team_forfeit }

      it 'displays for any user' do
        render
      end
    end

    context 'away team forfeit' do
      before { match.forfeit_by = :away_team_forfeit }

      it 'displays for any user' do
        render
      end
    end

    context 'mutual forfeit' do
      before { match.forfeit_by = :mutual_forfeit }

      it 'displays for any user' do
        render
      end
    end

    context 'technical forfeit' do
      before { match.forfeit_by = :technical_forfeit }

      it 'displays for any user' do
        render
      end
    end
  end

  context 'with schedule' do
    before do
      days = Array.new(5, true) + Array.new(2, false)
      scheduler = build(:league_schedulers_weekly, days: days, minimum_selected: 3)
      allow(league).to receive(:weekly_scheduler).and_return(scheduler)
      league.schedule = 'weeklies'

      schedule = { 'type' => 'weekly', 'availability' => {
        'Sunday' => 'true', 'Monday' => 'true', 'Tuesday' => 'true'
      } }
      home_team.schedule_data = schedule

      schedule['availability'] = {
        'Tuesday' => 'true', 'Wednesday' => 'true', 'Thursday' => 'true'
      }
      away_team.schedule_data = schedule
    end

    it 'displays schedule recomendation' do
      render

      expect(rendered).to include('Tuesday')
    end
  end

  context 'with pending pick bans' do
    let(:pick_bans) do
      [
        build_stubbed(:league_match_pick_ban, match: match, deferrable: true),
        build_stubbed(:league_match_pick_ban, match: match, team: :away_team, kind: :ban),
        build_stubbed(:league_match_pick_ban, match: match, team: :home_team, kind: :ban),
        build_stubbed(:league_match_pick_ban, match: match, team: :away_team, kind: :pick),
        build_stubbed(:league_match_pick_ban, match: match, team: :home_team, kind: :pick),
      ]
    end
    let(:map_pool) { build_stubbed_list(:map, 3) }

    before do
      assign(:pick_bans, pick_bans)
      allow(match).to receive(:pick_bans).and_return(pick_bans)
      allow(match).to receive(:picking_completed?).and_return(false)
      allow(match).to receive(:map_pool).and_return(map_pool)
    end

    include_examples 'displays matches'
  end

  context 'with completed pick bans' do
    let(:map) { build_stubbed(:map) }
    let(:user) { build_stubbed(:user) }
    let(:pick_bans) do
      [
        build_stubbed(:league_match_pick_ban, match: match, picked_by: user, team: :home_team, kind: :deferred),
        build_stubbed(:league_match_pick_ban, match: match, map: map, picked_by: user, team: :away_team, kind: :ban),
        build_stubbed(:league_match_pick_ban, match: match, map: map, picked_by: user, team: :home_team, kind: :ban),
        build_stubbed(:league_match_pick_ban, match: match, map: map, picked_by: user, team: :away_team, kind: :pick),
        build_stubbed(:league_match_pick_ban, match: match, map: map, picked_by: user, team: :home_team, kind: :pick),
      ]
    end
    let(:map_pool) { build_stubbed_list(:map, 3) }

    before do
      assign(:pick_bans, pick_bans)
      allow(match).to receive(:pick_bans).and_return(pick_bans)
      allow(match).to receive(:picking_completed?).and_return(true)
      allow(match).to receive(:map_pool).and_return(map_pool)
    end

    include_examples 'displays matches'
  end

  context 'with match date' do
    before { match.scheduled_at = Time.zone.now }

    include_examples 'displays matches'
  end
end
