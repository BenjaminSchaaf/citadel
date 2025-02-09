module Leagues
  module Matches
    class ScheduleEditsController < ApplicationController
      include ScheduleEditPermissions

      before_action only: :create do
        @match = League::Match.find(params[:match_id])
        @league = @match.league
      end
      before_action only: [:approve, :deny] do
        @edit = League::Match::ScheduleEdit.find(params[:id])
        @match = @edit.match
        @league = @match.league
      end
      before_action :require_can_create, only: :create
      before_action :require_can_decide, only: [:approve, :deny]

      def create
        @edit = ScheduleEdits::CreationService.call(@match, current_user, edit_params)

        redirect_to match_path(@match)
      end

      def approve
        ScheduleEdits::ApprovalService.call(@edit, current_user)

        redirect_to match_path(@match)
      end

      def deny
        ScheduleEdits::DenialService.call(@edit, current_user)

        redirect_to match_path(@match)
      end

      private

      def edit_params
        params.require(:schedule_edit).permit(:scheduled_at)
      end

      def redirect_to_match
        redirect_back(fallback_location: match_path(@match))
      end

      def require_can_create
        redirect_to_match unless user_can_create_schedule_edit?
      end

      def require_can_decide
        redirect_to_match unless user_can_decide_schedule_edit?
      end
    end
  end
end
