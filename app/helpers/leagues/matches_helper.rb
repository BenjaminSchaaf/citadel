module Leagues
  module MatchesHelper
    include MatchPermissions
    include Matches::PickBanPermissions
    include Matches::ScheduleEditPermissions

    def user_on_either_teams?(match = nil)
      match ||= @match
      match.home_team.on_roster?(current_user) || match.away_team&.on_roster?(current_user)
    end

    def division_select
      options_from_collection_for_select(@league.divisions, :id, :name, @division.id)
    end

    def tournament_systems
      League::Division::TOURNAMENT_SYSTEMS
    end

    def tournament_system_select
      options = tournament_systems.map { |system| [system.to_s.titleize, system] }

      options_for_select options, @tournament_system
    end

    def swiss_pairers
      League::Division::SWISS_PAIRERS
    end

    def swiss_parer_select
      options = swiss_pairers.map { |pairer| [pairer.to_s.titleize, pairer] }

      options_for_select options, @swiss_tournament[:pairer]
    end

    def swiss_push_byes_to_select
      options = [
        ['None', :none],
        ['Bottom Half', :bottom_half],
        ['Top Half', :top_half],
      ]

      options_for_select options, @swiss_tournament[:pair_options][:push_byes_to]
    end
  end
end
