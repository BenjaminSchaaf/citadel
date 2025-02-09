class League
  class Match
    class ScheduleEdit < ApplicationRecord
      belongs_to :match
      belongs_to :created_by, class_name: 'User'
      belongs_to :decided_by, class_name: 'User', optional: true
      enum deciding_team: [:home_team, :away_team]

      validate :validate_approved_iff_decided_by

      scope :ordered, -> { order(:updated_at) }
      scope :pending, -> { where(approved: nil) }

      def approve(user)
        transaction do
          match.update!(scheduled_at: scheduled_at)
          update!(decided_by: user, approved: true)
        end
      end

      def deny(user)
        update!(decided_by: user, approved: false)
      end

      def deciding_roster
        match.send(team_decide.first)
      end

      def requesting_roster
        match.send(team_decide.last)
      end

      def pending?
        approved.nil?
      end

      private

      def team_decide
        if home_team?
          [:home_team, :away_team]
        else
          [:away_team, :home_team]
        end
      end

      def validate_approved_iff_decided_by
        errors.add(:decided_by, 'must have decided_by when decided') \
          if decided_by.nil? && !approved.nil?
        errors.add(:approved, 'must be decided when decided_by is set') \
          if approved.nil? && !decided_by.nil?
      end
    end
  end
end
