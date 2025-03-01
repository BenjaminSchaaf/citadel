require 'rails_helper'

describe API::V1::MatchesController, type: :request do
  let(:api_key) { create(:api_key) }
  let(:match) { create(:league_match, status: :confirmed) }

  describe 'GET #show' do
    let(:route) { '/api/v1/matches' }

    it 'succeeds for existing match' do
      create_list(:league_match_round, 3, match: match, home_team_score: 12)

      get "#{route}/#{match.id}", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      match_h = json['match']
      expect(match_h).to_not be_nil
      expect(match_h['forfeit_by']).to eq(match.forfeit_by)
      expect(match_h['status']).to eq(match.status)
      expect(match_h['scheduled_at']).to eq(match.scheduled_at)
      expect(match_h['league']['name']).to eq(match.league.name)
      expect(match_h['home_team']['name']).to eq(match.home_team.name)
      expect(match_h['away_team']['name']).to eq(match.away_team.name)

      teams = [match_h['home_team'], match_h['away_team']]
      teams.each do |team|
        expect(team['players']).to_not be_empty
      end

      match_h['rounds'].each do |round|
        expect(round['home_team_score']).to eq(12)
      end

      expect(response).to be_successful
    end

    it 'succeeds for non-existent match' do
      get "#{route}/-1", headers: { 'X-API-Key' => api_key.key }

      json = response.parsed_body
      expect(json['status']).to eq(404)
      expect(json['message']).to eq('Record not found')
      expect(response).to be_not_found
    end
  end
end
