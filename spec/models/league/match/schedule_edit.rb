require 'rails_helper'

describe League::Match::ScheduleEdit do
  let(:creator) { create(:user) }
  let(:decider) { create(:user) }
  let(:edit) { create(:league_match_schedule_edit, created_by: creator) }

  it { is_expected.to belong_to :match }
  it { is_expected.to belong_to :created_by }
  it { is_expected.to belong_to(:decided_by).optional }
  it { is_expected.to define_enum_for(:deciding_team).with_values([:home_team, :away_team]) }

  it { expect(edit).to be_valid }
  it 'is valid when decided' do
    edit.decided_by = decider
    edit.approved = true
    expect(edit).to be_valid
  end

  describe '#decided_by' do
    it 'is required when approved' do
      edit.approved = true
      edit.valid?
      expect(edit.errors[:decided_by].size).to eq 1
    end
  end

  describe '#approved' do
    it 'is required when decided_by' do
      edit.decided_by = decider
      edit.valid?
      expect(edit.errors[:approved].size).to eq 1
    end
  end

  it 'approves a request', :aggregate_failures do
    edit = create(:league_match_schedule_edit, created_by: creator)

    expect(edit.approve(decider)).to be true
    edit.reload
    edit.match.reload
    expect(edit.match.scheduled_at).to eq edit.scheduled_at
    expect(edit.approved).to be true
    expect(edit.decided_by).to eq decider
  end

  it 'denies a request', :aggregate_failures do
    edit = create(:league_match_schedule_edit, created_by: creator)

    expect(edit.deny(decider)).to be true
    edit.reload
    edit.match.reload
    expect(edit.match.scheduled_at).to be nil
    expect(edit.approved).to be false
    expect(edit.decided_by).to eq decider
  end
end
