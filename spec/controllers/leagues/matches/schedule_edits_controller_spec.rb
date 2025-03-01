require 'rails_helper'

describe Leagues::Matches::ScheduleEditsController do
  let(:user) { create(:user) }
  let(:edit) { create(:league_match_schedule_edit, created_by: user) }
  let(:match) { edit.match }
  let(:scheduled_at) { edit.scheduled_at }

  shared_examples 'redirects' do
    it 'redirects to the match page' do
      request
      expect(response).to redirect_to(match_path(match))
    end
  end

  # Submitted by home/away team omitted to speed up tests
  shared_examples 'pending/submitted' do |pending, submitted|
    context 'when match.status is pending' do
      include_examples pending
    end

    context 'when match.status is confirmed' do
      before { match.update(status: :confirmed) }

      include_examples submitted
    end
  end

  describe 'POST #create' do
    service = Leagues::Matches::ScheduleEdits::CreationService
    before { allow(service).to receive(:call).and_return(edit) }

    def request
      post :create, params: {
        match_id:      match.id,
        schedule_edit: { scheduled_at: scheduled_at },
      }
    end

    shared_examples 'succeeds' do
      let(:edit_params) do
        ActionController::Parameters.new(scheduled_at: scheduled_at.to_s)
                                    .permit(:scheduled_at)
      end

      include_examples 'redirects'

      it 'calls CreationService' do
        expect(service).to receive(:call).with(match, user, edit_params)
        request
      end
    end

    shared_examples 'fails' do
      include_examples 'redirects'

      it "doesn't call CreationService" do
        expect(service).not_to receive(:call)
        request
      end
    end

    shared_examples 'user' do |result|
      context 'when user is admin' do
        before do
          user.grant(:edit, match.league)
          sign_in user
        end

        include_examples 'pending/submitted', 'succeeds', 'succeeds'
      end

      context 'when user can edit home_team' do
        before do
          user.grant(:edit, match.home_team.team)
          sign_in user
        end

        include_examples 'pending/submitted', result, 'fails'
      end

      context 'when user can edit away_team' do
        before do
          user.grant(:edit, match.away_team.team)
          sign_in user
        end

        include_examples 'pending/submitted', result, 'fails'
      end

      context "when user isn't logged in" do
        include_examples 'pending/submitted', 'fails', 'fails'
      end
    end

    context "when league doesn't allow rescheduling" do
      before { match.league.update(allow_rescheduling: false) }

      include_examples 'user', 'fails'
    end

    context 'when league allows rescheduling' do
      include_examples 'user', 'succeeds'
    end
  end

  shared_examples 'decides' do |service|
    before { allow(service).to receive(:call).and_return(true) }

    def request
      patch endpoint, params: { id: edit.id }
    end

    shared_examples 'succeeds' do
      include_examples 'redirects'

      it "calls #{service.name.split(':').last}" do
        expect(service).to receive(:call).with(edit, user)
        request
      end
    end

    shared_examples 'fails' do
      include_examples 'redirects'

      it "doesn't call #{service.name.split(':').last}" do
        expect(service).not_to receive(:call)
        request
      end
    end

    shared_examples 'home/away' do |home, away|
      context 'when user can edit home_team' do
        before do
          user.grant(:edit, match.home_team.team)
          sign_in user
        end

        include_examples 'pending/submitted', home, 'fails'
      end

      context 'when user can edit away_team' do
        before do
          user.grant(:edit, match.away_team.team)
          sign_in user
        end

        include_examples 'pending/submitted', away, 'fails'
      end
    end

    shared_examples 'user' do |result|
      context 'when user is admin' do
        before do
          user.grant(:edit, match.league)
          sign_in user
        end

        include_examples 'pending/submitted', result, result
      end

      context 'when deciding team is home' do
        include_examples 'home/away', result, 'fails'
      end

      context 'when deciding team is away' do
        before { edit.update(deciding_team: :away_team) }

        include_examples 'home/away', 'fails', result
      end

      context "when user isn't logged in" do
        include_examples 'pending/submitted', 'fails', 'fails'
      end
    end

    context 'when edit is pending' do
      include_examples 'user', 'succeeds'
    end

    # denied ommitted to speed up tests
    context 'when edit is decided' do
      before { edit.update(approved: true, decided_by: user) }

      include_examples 'user', 'fails'
    end
  end

  describe 'PATCH #approve' do
    let(:endpoint) { :approve }

    include_examples 'decides', Leagues::Matches::ScheduleEdits::ApprovalService
  end

  describe 'PATCH #deny' do
    let(:endpoint) { :deny }

    include_examples 'decides', Leagues::Matches::ScheduleEdits::DenialService
  end
end
