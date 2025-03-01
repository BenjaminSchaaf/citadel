require 'rails_helper'
require_relative './shared'

describe Leagues::Matches::ScheduleEdits::DenialService do
  include_context 'with captains'

  it 'denies a reschedule request', :aggregate_failures do
    edit = create(:league_match_schedule_edit, created_by: user, match: match,
                  deciding_team: :away_team)

    subject.call(edit, away_captain)
    edit.reload
    expect(edit).to be_valid
    expect(edit.approved).to be(false)
    expect(edit.decided_by).to eq(away_captain)
    match.reload
    expect(match.scheduled_at).to be_nil

    expect(user.notifications).not_to be_empty
    expect(home_captain.notifications).not_to be_empty
    expect(away_captain.notifications).to be_empty
    expect(match.users.map(&:notifications)).to all(be_empty)
  end
end
