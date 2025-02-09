module Leagues
  module Matches
    module CreationService
      include BaseService

      def call(params)
        match = League::Match.new(params)

        match.transaction do
          match.save || rollback!

          notify_for_match!(match)
        end

        match
      end

      def notify_for_match!(match)
        msg  = notify_message(match)
        link = match_path(match)

        users_to_notify(match).find_each do |user|
          Users::NotificationService.call(user, message: msg, link: link)
        end
      end

      private

      def users_to_notify(match)
        users = match.home_team.users

        if match.bye?
          users
        else
          users.union(match.away_team.users)
        end
      end

      def notify_message(match)
        msg = if match.bye?
                "You have a match BYE for #{match.home_team.name}"
              else
                "You have an upcoming match: #{match.home_team.name} vs #{match.away_team.name}"
              end

        msg << if match.scheduled_at
                 " scheduled for #{match.scheduled_at.strftime('%c')}."
               else
                 '.'
               end
      end
    end
  end
end
