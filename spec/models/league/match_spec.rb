require 'rails_helper'

describe League::Match do
  before(:all) { create(:league_match) }

  it { should belong_to(:home_team).class_name('League::Roster') }

  it { should belong_to(:away_team).class_name('League::Roster').optional }

  it { should belong_to(:winner).class_name('League::Roster').optional }

  it { should belong_to(:loser).class_name('League::Roster').optional }

  it { should have_many(:rounds).class_name('Match::Round').dependent(:destroy) }
  it { should accept_nested_attributes_for(:rounds) }

  it { should have_many(:pick_bans).class_name('Match::PickBan').dependent(:destroy) }
  it { should accept_nested_attributes_for(:pick_bans) }

  it { should have_many(:comms).class_name('Match::Comm').dependent(:destroy) }

  it { should have_many(:schedule_edits).class_name('Match::ScheduleEdit').dependent(:destroy) }

  it { should allow_value('').for(:round_name) }
  it { should validate_length_of(:round_name).is_at_least(0) }

  it { should validate_numericality_of(:round_number).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:round_number) }

  it { should allow_value('').for(:notice) }
  it { should validate_length_of(:notice).is_at_least(0) }

  it do
    should define_enum_for(:status).with_values([:pending, :submitted_by_home_team, :submitted_by_away_team,
                                                 :confirmed])
  end

  it do
    should define_enum_for(:forfeit_by).with_values([:no_forfeit, :home_team_forfeit, :away_team_forfeit,
                                                     :mutual_forfeit, :technical_forfeit])
  end

  describe 'validation' do
    describe 'before' do
      it 'confirms on forfeit' do
        match = build(:league_match, status: :pending, forfeit_by: :no_forfeit)

        match.run_callbacks(:validation) do
          expect(match.status).to eq('pending')
        end

        match.forfeit_by = :home_team_forfeit

        match.run_callbacks(:validation) do
          expect(match.status).to eq('confirmed')
        end

        match.status = :submitted_by_home_team
        match.forfeit_by = :technical_forfeit

        match.run_callbacks(:validation) do
          expect(match.status).to eq('confirmed')
        end
      end

      it 'confirms and removes rounds for byes' do
        match = build(:bye_league_match)

        match.status = :submitted_by_home_team
        match.forfeit_by = :mutual_forfeit
        match.rounds = [build(:league_match_round, match: match, home_team_score: 0, away_team_score: 0)]

        match.run_callbacks(:validation) do
          expect(match.status).to eq('confirmed')
          expect(match.forfeit_by).to eq('no_forfeit')
          expect(match.rounds).to be_empty
        end
      end

      it 'updates round outcomes' do
        map = build(:map)
        rounds = [League::Match::Round.new(map: map, home_team_score: 0, away_team_score: 1),
                  League::Match::Round.new(map: map, home_team_score: 0, away_team_score: 1),
                  League::Match::Round.new(map: map, home_team_score: 2, away_team_score: 1)]
        match = build(:league_match, rounds: rounds, has_winner: true)

        match.status = :pending
        match.run_callbacks(:validation) do
          rounds.each do |round|
            expect(round.has_outcome).to be(false)
          end
        end

        match.has_winner = false
        match.status = :submitted_by_home_team
        match.run_callbacks(:validation) do
          rounds.each do |round|
            expect(round.has_outcome).to be(true)
          end
        end

        match.has_winner = true
        match.status = :submitted_by_away_team
        match.run_callbacks(:validation) do
          expect(rounds[0].has_outcome).to be(true)
          expect(rounds[1].has_outcome).to be(true)
          expect(rounds[2].has_outcome).to be(false)
        end

        rounds[0].home_team_score = 1
        rounds[1].home_team_score = 1
        match.run_callbacks(:validation) do
          expect(rounds[0].has_outcome).to be(true)
          expect(rounds[1].has_outcome).to be(true)
          expect(rounds[2].has_outcome).to be(true)
        end

        match.forfeit_by = :home_team_forfeit
        match.run_callbacks(:validation) do
          rounds.each do |round|
            expect(round.has_outcome).to be(false)
          end
        end

        match.forfeit_by = :no_forfeit
        match.away_team = nil
        match.run_callbacks(:validation) do
          rounds.each do |round|
            expect(round.has_outcome).to be(false)
          end
        end
      end
    end

    it 'validates that matches with winners cannot have draws' do
      rounds = build_list(:league_match_round, 3)
      expect(build(:league_match, rounds: rounds, has_winner: false, allow_round_draws: false)).to be_valid
      expect(build(:league_match, rounds: rounds, has_winner: false, allow_round_draws: true)).to be_valid
      expect(build(:league_match, rounds: rounds, has_winner: true, allow_round_draws: false)).to be_valid
      expect(build(:league_match, rounds: rounds, has_winner: true, allow_round_draws: true)).to be_invalid
    end

    it 'validates scores' do
      map = build(:map)
      round_fn = -> { League::Match::Round.new(map: map) }
      rounds = [round_fn.call, round_fn.call, round_fn.call]
      match = build(:league_match, rounds: rounds, has_winner: true, allow_round_draws: false)
      rounds.each { |round| round.run_callbacks(:save) }

      expect(match).to be_valid
      match.run_callbacks(:save) do
        expect(match.winner).to be nil
        expect(match.loser).to be nil
      end

      match.rounds[0].home_team_score = 2
      match.status = :submitted_by_home_team
      expect(match).to be_invalid

      match.rounds[1].home_team_score = 2
      expect(match).to be_valid

      match.rounds[1].run_callbacks(:save)
      expect(match.rounds[1].winner).to eq(match.home_team)
      match.run_callbacks(:save) do
        expect(match.winner).to eq(match.home_team)
        expect(match.loser).to eq(match.away_team)
      end

      match.rounds[1].away_team_score = 4
      expect(match).to be_invalid

      match.rounds[2].away_team_score = 4
      expect(match).to be_valid

      match.rounds[2].run_callbacks(:save)
      expect(match.rounds[2].winner).to eq(match.away_team)
      match.run_callbacks(:save) do
        expect(match.winner).to eq(match.away_team)
        expect(match.loser).to eq(match.home_team)
      end
    end

    it 'validates forfeits' do
      match = build(:league_match, has_winner: true, rounds: [build(:league_match_round)])

      match.forfeit_by = :away_team_forfeit

      expect(match).to be_valid
      match.run_callbacks(:save) do
        expect(match.winner).to eq(match.home_team)
        expect(match.loser).to eq(match.away_team)
      end

      match.forfeit_by = :home_team_forfeit

      expect(match).to be_valid
      match.run_callbacks(:save) do
        expect(match.winner).to eq(match.away_team)
        expect(match.loser).to eq(match.home_team)
      end

      match.forfeit_by = :mutual_forfeit

      expect(match).to be_valid
      match.run_callbacks(:save) do
        expect(match.winner).to be nil
        expect(match.loser).to be nil
      end

      match.forfeit_by = :technical_forfeit

      expect(match).to be_invalid
      match.run_callbacks(:save) do
        expect(match.winner).to be nil
        expect(match.loser).to be nil
      end
    end

    it 'validates byes' do
      match = build(:bye_league_match, has_winner: true)

      expect(match).to be_valid
      match.run_callbacks(:save) do
        expect(match.winner).to eq(match.home_team)
        expect(match.loser).to be nil
      end
    end
  end

  describe 'calculations' do
    it 'calculates score totals before save' do
      map = build(:map)
      rounds = [League::Match::Round.new(map: map, home_team_score: 0, away_team_score: 1),
                League::Match::Round.new(map: map, home_team_score: 0, away_team_score: 5),
                League::Match::Round.new(map: map, home_team_score: 3, away_team_score: 2),
                League::Match::Round.new(map: map, home_team_score: 2, away_team_score: 2),
                League::Match::Round.new(map: map, home_team_score: 4, away_team_score: 0)]
      match = build(:league_match, rounds: rounds, has_winner: false, allow_round_draws: true, status: :confirmed)

      rounds.each { |round| round.run_callbacks(:save) }

      match.run_callbacks(:save) do
        expect(match.total_home_team_score).to eq(9)
        expect(match.total_away_team_score).to eq(10)
        expect(match.total_score_difference).to eq(-1)
      end
    end
  end

  describe 'pick bans' do
    it 'sets order numbers before validation' do
      map = build(:map)
      rounds = [League::Match::Round.new(map: map)]
      pick_bans = [
        League::Match::PickBan.new(kind: :pick, team: :home_team, deferrable: true),
        League::Match::PickBan.new(kind: :ban,  team: :home_team, deferrable: false),
        League::Match::PickBan.new(kind: :pick, team: :away_team, deferrable: false),
      ]
      match = build(:league_match, rounds: rounds, pick_bans: pick_bans, has_winner: false, allow_round_draws: false)

      expect(match.valid?).to be(true)

      expect(match.pick_bans.length).to eq(3)
      expect(match.pick_bans[0].order_number).to eq(0)
      expect(match.pick_bans[1].order_number).to eq(1)
      expect(match.pick_bans[2].order_number).to eq(2)
    end
  end

  describe '#forfeit!' do
    let(:match) { create(:league_match) }
    it 'forfeits for the home team' do
      match.forfeit!(match.home_team)
      expect(match.forfeit_by).to eq('home_team_forfeit')
    end

    it 'forfeits for the away team' do
      match.forfeit!(match.away_team)
      expect(match.forfeit_by).to eq('away_team_forfeit')
    end

    it 'keeps old forfeit state' do
      match = create(:league_match)
      match.forfeit!(match.home_team)
      expect(match.forfeit_by).to eq('home_team_forfeit')

      match.forfeit!(match.home_team)
      expect(match.forfeit_by).to eq('home_team_forfeit')

      match.forfeit!(match.away_team)
      expect(match.forfeit_by).to eq('mutual_forfeit')
    end
  end
end
