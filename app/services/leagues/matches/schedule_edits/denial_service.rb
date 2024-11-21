module Leagues
  module Matches
    module ScheduleEdits
      module DenialService
        include BaseService
        extend ScheduleEditServicer

        def call(edit, user)
          edit.transaction do
            edit.deny(user)
            notify_captains(edit, edit.requesting_roster, reschedule_msg(user, 'denied', edit))
          end
        end
      end
    end
  end
end
