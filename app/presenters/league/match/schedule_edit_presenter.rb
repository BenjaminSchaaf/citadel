class League
  class Match
    class ScheduleEditPresenter < BasePresenter
      presents :edit

      # rubocop:disable Rails/OutputSafety
      def to_s
        if edit.approved.nil?
          safe_join([created_by.link, raw(' requested reschedule to <b>'), scheduled_at,
                     raw('</b>')])
        else
          safe_join([decided_by.link, ' ', status, raw(' reschedule to <b>'), scheduled_at,
                     raw('</b> as requested by '), created_by.link])
        end
      end
      # rubocop:enable Rails/OutputSafety

      def created_by
        @created_by ||= present(edit.created_by)
      end

      def decided_by
        @decided_by ||= present(edit.decided_by)
      end

      def status
        edit.approved? ? 'approved' : 'denied'
      end

      def scheduled_at
        edit.scheduled_at.strftime('%c')
      end
    end
  end
end
