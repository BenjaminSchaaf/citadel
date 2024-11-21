module Leagues
  module Matches
    module ScheduleEditPermissions
      extend ActiveSupport::Concern
      include ::Leagues::MatchPermissions

      def user_can_create_schedule_edit?
        return true if user_can_edit_league?
        return false unless @league.allow_rescheduling
        return false unless @match.status == 'pending'
        user_can_home_team? || user_can_away_team?
      end

      def user_can_decide_schedule_edit?(edit: nil)
        edit ||= @edit

        return false unless edit.pending?
        return true if user_can_edit_league?
        return false unless @match.status == 'pending'
        edit.home_team? ? user_can_home_team? : user_can_away_team?
      end
    end
  end
end
