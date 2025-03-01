require 'rails_helper'
require_relative './shared'

describe Leagues::Matches::ScheduleEdits::ApprovalService do
  include_context 'with captains'

  it 'approves a reschedule request', :aggregate_failures do
    edit = create(:league_match_schedule_edit, created_by: user, match: match)

    subject.call(edit, away_captain)
    edit.reload
    expect(edit).to be_valid
    expect(edit.approved).to be true
    expect(edit.decided_by).to eq away_captain
    match.reload
    expect(match.scheduled_at).to eq edit.scheduled_at

    expect(user.notifications).to be_empty
    expect(home_captain.notifications).to be_empty
    expect(away_captain.notifications).to be_empty
    expect(match.users.map(&:notifications)).not_to include(be_empty)
  end

  context 'with other edits' do
    include_context 'with schedule edits'

    it 'denies other pending requests', :aggregate_failures do
      edit = create(:league_match_schedule_edit, created_by: away_captain, match: match)
      subject.call(edit, user)
      other_edit.reload
      pending_edit.reload
      approved_edit.reload

      expect(edit.approved).to be true
      expect(edit.decided_by).to eq user
      expect(other_edit.approved).to be false
      expect(other_edit.decided_by).to eq user
      expect(pending_edit.approved).to be false
      expect(pending_edit.decided_by).to eq user
      expect(approved_edit.approved).to be true
      expect(approved_edit.decided_by).to eq away_captain
    end
  end
end
