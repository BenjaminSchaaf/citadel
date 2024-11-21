shared_context 'with captains' do
  let(:match) { create(:league_match) }
  let(:user) { create(:user) }
  let(:home_captain) { create(:user) }
  let(:away_captain) { create(:user) }

  before do
    user.grant(:edit, match.home_team.team)
    home_captain.grant(:edit, match.home_team.team)
    away_captain.grant(:edit, match.away_team.team)
    ActionMailer::Base.deliveries.clear
  end
end

shared_context 'with schedule edits' do
  let!(:other_edit) { create(:league_match_schedule_edit, created_by: home_captain, match: match) }
  let!(:pending_edit) { create(:league_match_schedule_edit, created_by: user, match: match) }
  let!(:approved_edit) { create(:league_match_schedule_edit, created_by: user, match: match) }

  before { approved_edit.approve(away_captain) }
end
