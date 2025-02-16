require 'rails_helper'

describe LeaguesController do
  let(:admin) { create(:user) }
  let(:map) { create(:map) }

  before do
    admin.grant(:edit, :leagues)
  end

  describe 'GET #index' do
    before do
      create_list(:league, 5)
    end

    it 'succeeds' do
      get :index

      expect(response).to have_http_status(:success)
    end

    it 'succeeds with search' do
      get :index, params: { q: 'foo' }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'succeeds for authorized user' do
      sign_in admin

      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:format) { create(:format) }

    it 'succeeds for authorized user' do
      sign_in admin

      # TODO: Test missing league params
      post :create, params: {
        league: { name: 'A', description: 'B', format_id: format.id, category: 'foo',
                  signuppable: true, hide_rosters: true, roster_locked: false, matches_submittable: true,
                  transfers_require_approval: false, allow_disbanding: true,
                  forfeit_all_matches_when_roster_disbands: false, min_players: 1, max_players: 3,
                  points_per_round_win: 3, points_per_round_draw: 2,
                  points_per_round_loss: 1, points_per_match_win: 5,
                  points_per_match_draw: 6, points_per_match_loss: 7,
                  schedule_locked: true,
                  schedule: 'weeklies', divisions_attributes: [{ name: 'PREM' }],
                  pooled_maps_attributes: [{ map_id: map.id }],
                  tiebreakers_attributes: [{ kind: 'round_wins' },
                                           { kind: 'round_score_difference' }],
                  weekly_scheduler_attributes: {
                    start_of_week: 'Monday', minimum_selected: 2,
                    days_indecies: [0, 1, 3, 5, 6]
                  } },
      }

      comp = League.first
      expect(comp.name).to eq('A')
      expect(comp.description).to eq('B')
      expect(comp.format).to eq(format)
      expect(comp.category).to eq('foo')
      expect(comp.signuppable).to be(true)
      expect(comp.hide_rosters).to be(true)
      expect(comp.roster_locked).to be(false)
      expect(comp.matches_submittable).to be(true)
      expect(comp.transfers_require_approval).to be(false)
      expect(comp.allow_disbanding).to be(true)
      expect(comp.forfeit_all_matches_when_roster_disbands).to be(false)
      expect(comp.min_players).to eq(1)
      expect(comp.max_players).to eq(3)
      expect(comp.points_per_round_win).to eq(3)
      expect(comp.points_per_round_draw).to eq(2)
      expect(comp.points_per_round_loss).to eq(1)
      expect(comp.points_per_match_win).to eq(5)
      expect(comp.points_per_match_draw).to eq(6)
      expect(comp.points_per_match_loss).to eq(7)
      expect(comp.divisions.size).to eq(1)
      div = comp.divisions.first
      expect(div.name).to eq('PREM')
      expect(comp.tiebreakers.size).to eq(2)
      pooled_map = comp.pooled_maps.first
      expect(pooled_map).to_not be_nil
      expect(pooled_map.map).to eq(map)
      tieb1 = comp.tiebreakers.first
      expect(tieb1.kind).to eq('round_wins')
      tieb2 = comp.tiebreakers.last
      expect(tieb2.kind).to eq('round_score_difference')
      expect(comp.schedule_locked).to be(true)
      expect(comp.schedule).to eq('weeklies')
      scheduler = comp.weekly_scheduler
      expect(scheduler.start_of_week).to eq('Monday')
      expect(scheduler.minimum_selected).to eq(2)
      expect(scheduler.days).to eq([true, true, false, true, false, true, true])
    end

    it 'fails for invalid data' do
      sign_in admin

      post :create, params: {
        league: { name: 'A', description: 'B', format_id: format.id, signuppable: true,
                  roster_locked: false, matches_submittable: true, min_players: 5,
                  max_players: 3, divisions_attributes: [{ name: 'PREM' }] },
      }

      expect(League.first).to be(nil)
    end

    it 'redirects for unauthorized user' do
      sign_in create(:user)

      post :create

      expect(response).to redirect_to(leagues_path)
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }
    let!(:comp) { create(:league) }
    let!(:div) { create(:league_division, league: comp) }

    it 'succeeds for users on a roster' do
      roster = create(:league_roster, division: div)
      roster.add_player!(user)
      sign_in user

      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for any user' do
      sign_in user

      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for anyone' do
      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #medals' do
    let(:user) { create(:user) }
    let!(:comp) { create(:league) }
    let!(:div) { create(:league_division, league: comp) }

    it 'succeeds for authorized user' do
      sign_in admin
      get :edit, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for users on a roster' do
      roster = create(:league_roster, division: div)
      roster.add_player!(user)
      sign_in user

      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for any user' do
      sign_in user

      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end

    it 'succeeds for anyone' do
      get :show, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    let(:comp) { create(:league) }

    it 'succeeds for authorized user' do
      sign_in admin

      get :edit, params: { id: comp.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    let(:format) { create(:format) }
    let(:format2) { create(:format) }
    let(:comp) { create(:league, format: format) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :update, params: {
        id: comp.id, league: {
          name: 'A', description: 'B', format_id: format2.id, signuppable: true, hide_rosters: true,
          roster_locked: false, matches_submittable: true, transfers_require_approval: false,
          min_players: 1, max_players: 3, divisions_attributes: [{ name: 'PREM' }]
        }
      }

      comp.reload
      expect(comp.name).to eq('A')
      expect(comp.description).to eq('B')
      expect(comp.format).to eq(format2)
      expect(comp.signuppable).to be(true)
      expect(comp.hide_rosters).to be(true)
      expect(comp.roster_locked).to be(false)
      expect(comp.matches_submittable).to be(true)
      expect(comp.transfers_require_approval).to be(false)
      expect(comp.min_players).to eq(1)
      expect(comp.max_players).to eq(3)
      expect(comp.divisions.size).to eq(1)
      div = comp.divisions.first
      expect(div.name).to eq('PREM')
    end

    it 'fails for authorized user' do
      sign_in admin

      patch :update, params: {
        id: comp.id, league: {
          name: '', description: 'B', format_id: format.id, signuppable: true,
          roster_locked: false, matches_submittable: true, min_players: 5, max_players: 3,
          divisions_attributes: [{ name: 'PREM' }]
        }
      }

      comp.reload
      expect(comp.name).not_to eq('')
    end

    it 'redirects for unauthorized user' do
      sign_in create(:user)

      patch :update, params: { id: comp.id }

      expect(response).to redirect_to(league_path(comp))
    end
  end

  describe 'PATCH #modify' do
    let(:comp) { create(:league, status: :hidden) }

    it 'succeeds for authorized user' do
      sign_in admin

      patch :modify, params: { id: comp.id, status: 'running' }

      comp.reload
      expect(comp.status).to eq('running')
    end
  end

  describe 'DELETE #destroy' do
    let(:comp) { create(:league, status: :hidden) }

    it 'succeeds for hidden league' do
      sign_in admin

      delete :destroy, params: { id: comp.id }

      expect(League.count).to eq(0)
    end

    it 'fails for public league' do
      comp.status = 'running'
      comp.save!
      sign_in admin

      delete :destroy, params: { id: comp.id }

      expect(League.first).to eq(comp)
    end
  end
end
