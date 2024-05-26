module Leagues
  module Matches
    module ScheduleEdits
      module CreationService
        include BaseService
        extend ScheduleEditServicer

        # rubocop:disable Metrics/MethodLength
        def call(match, user, params)
          team = if match.bye? || user.can?(:edit, match.away_team.team)
                   :home_team
                 else
                   :away_team
                 end

          edit_params = params.merge(created_by: user, deciding_team: team)
          edit = match.schedule_edits.new(edit_params)
          edit.transaction do
            # Cancel any existing proposed match dates
            match.schedule_edits
                 .pending
                 .where(created_by: user)
                 .where.not(id: edit.id)
                 .each { |e| e.deny(user) }
            edit.save!
            notify_captains(edit, edit.deciding_roster, reschedule_msg(user, 'requested', edit))
          end

          edit
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
