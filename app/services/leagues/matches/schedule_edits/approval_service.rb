module Leagues
  module Matches
    module ScheduleEdits
      module ApprovalService
        include BaseService
        extend ScheduleEditServicer

        def call(edit, user)
          edit.transaction do
            # Deny other proposed match dates
            edit.match.schedule_edits
                .pending
                .where.not(id: edit.id)
                .each { |e| e.deny(user) }
            edit.approve(user)

            notify(edit.match.users, reschedule_msg(user, 'approved', edit),
                   match_path(edit.match))
          end
        end
      end
    end
  end
end
