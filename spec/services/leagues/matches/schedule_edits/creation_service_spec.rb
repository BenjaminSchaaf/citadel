require 'rails_helper'
require_relative './shared'

describe Leagues::Matches::ScheduleEdits::CreationService do
  include_context 'with captains'

  it 'creates a reschedule request', :aggregate_failures do
    scheduled_at = Time.now.utc
    edit = subject.call(match, user, scheduled_at: scheduled_at)

    expect(edit).to be_valid
    expect(edit.created_by).to be(user)
    expect(edit.scheduled_at).to eq(scheduled_at)
    expect(edit.away_team?).to be(true)
    expect(edit.pending?).to be(true)

    expect(match.schedule_edits).not_to be_empty
    expect(match.scheduled_at).to be_nil

    expect(user.notifications).not_to be_empty
    expect(home_captain.notifications).to be_empty
    expect(away_captain.notifications).not_to be_empty
    expect(match.users.map(&:notifications)).to all(be_empty)
  end

  it 'sets deciding_team to the other team' do
    expect(subject.call(match, user, scheduled_at: Time.now.utc).deciding_team).to eq 'away_team'
  end

  it 'sets deciding_team to :home_team for BYEs' do
    expect(subject.call(create(:bye_league_match), user, scheduled_at: Time.now.utc)
                  .deciding_team).to eq 'home_team'
  end

  context 'with other edits' do
    include_context 'with schedule edits'

    it 'cancels non-pending requests from the same user', :aggregate_failures do
      edit = subject.call(match, user, scheduled_at: Time.now.utc)
      other_edit.reload
      pending_edit.reload
      approved_edit.reload

      expect(edit.approved).to be nil
      expect(edit.decided_by).to be nil
      expect(other_edit.approved).to be nil
      expect(other_edit.decided_by).to be nil
      expect(pending_edit.approved).to be false
      expect(pending_edit.decided_by).to eq user
      expect(approved_edit.approved).to be true
      expect(approved_edit.decided_by).to eq away_captain
    end
  end
end
