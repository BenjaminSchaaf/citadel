require 'rails_helper'

describe 'leagues/show' do
  let(:league) { build_stubbed(:league) }
  let(:divisions) { build_stubbed_list(:league_division, 3) }
  let(:roster) { build_stubbed(:league_roster) }
  let(:matches) do
    [
      build_stubbed(:league_match, status: :confirmed, scheduled_at: Time.zone.now),
      build_stubbed(:league_match, status: :confirmed, forfeit_by: :home_team_forfeit),
      build_stubbed(:league_match, status: :confirmed, forfeit_by: :away_team_forfeit),
      build_stubbed(:league_match, status: :confirmed, forfeit_by: :mutual_forfeit),
      build_stubbed(:league_match, status: :confirmed, forfeit_by: :technical_forfeit),
      build_stubbed(:bye_league_match),
    ]
  end

  before do
    all_rosters = []
    ordered_rosters = []
    divisions.each do |division|
      rosters = build_stubbed_list(:league_roster, 5)
      all_rosters += rosters
      ordered_rosters << [division, rosters]
    end
    allow(league).to receive(:ordered_rosters_by_division).and_return(ordered_rosters)

    tiebreakers = League::Tiebreaker.kinds.map do |kind, _|
      build_stubbed(:league_tiebreaker, kind: kind)
    end
    allow(league).to receive(:tiebreakers).and_return(tiebreakers)

    assign(:league, league)
    assign(:rosters, all_rosters)
    assign(:ordered_rosters, ordered_rosters)
    assign(:divisions, divisions)
    assign(:roster, roster)
    assign(:matches, divisions.map { |div| [div, matches] }.to_h)
  end

  context 'hidden league' do
    before { league.status = 'hidden' }

    it 'displays league details for' do
      assign(:top_div_matches, matches)

      render

      expect(rendered).to include(league.name)
      expect(rendered).to include('Private')
    end
  end

  context 'league with signups open' do
    before do
      # Fake login
      allow(view).to receive(:user_signed_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(build(:user))

      league.signuppable = true
    end

    it 'displays league details' do
      assign(:personal_matches, matches)

      render

      expect(rendered).to include(league.name)
      divisions.each do |division|
        expect(rendered).to_not include(division.name)

        division.rosters.active.each do |roster|
          expect(rendered).to include(roster.name)
        end
      end
    end
  end

  it 'displays league details' do
    assign(:top_div_matches, matches)

    render

    expect(rendered).to include(league.name)
    divisions.each do |division|
      expect(rendered).to include(division.name)

      division.rosters.active.each do |roster|
        expect(rendered).to include(roster.name)
      end
    end
  end
end
