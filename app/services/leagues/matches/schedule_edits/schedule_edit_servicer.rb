module Leagues
  module Matches
    module ScheduleEdits
      module ScheduleEditServicer
        include BaseService

        def reschedule_msg(user, action, edit)
          match_name = if edit.match.bye?
                         "BYE for '#{edit.match.home_team.name}'"
                       else
                         "'#{edit.match.home_team.name}' vs '#{edit.match.away_team.name}'"
                       end
          "'#{user.name}' #{action} rescheduling #{match_name} to "\
            "#{edit.scheduled_at.strftime('%c')}"
        end

        def notify(users, msg, link)
          users.each do |user|
            Users::NotificationService.call(user, message: msg, link: link)
          end
        end

        def notify_captains(edit, roster, msg)
          captains = User.which_can(:edit, roster.team)
          link = match_path(edit.match)
          notify(captains, msg, link)
          Users::NotificationService.call(edit.created_by, message: msg, link: link) \
            unless captains.include?(edit.created_by)
        end
      end
    end
  end
end
