FactoryBot.define do
  factory :league_match_schedule_edit, class: 'League::Match::ScheduleEdit' do
    association :match, factory: :league_match
    created_by {}
    decided_by { nil }
    deciding_team { :home_team }
    scheduled_at { Time.now.utc }
    approved { nil }
  end
end
