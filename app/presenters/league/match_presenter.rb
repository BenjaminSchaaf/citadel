class League
  class MatchPresenter < BasePresenter
    presents :match

    delegate :id, to: :match
    delegate :league, to: :match
    delegate :bye?, to: :match

    def home_team
      present(match.home_team)
    end

    def away_team
      present(match.away_team) unless match.away_team.nil?
    end

    def to_s
      match_s(&:to_s)
    end

    def short_round_s
      match.round_name.presence || "##{match.round_number}"
    end

    def round_s
      match.round_name.presence || "Round ##{match.round_number}"
    end

    def title
      match_s(&:link)
    end

    def link(label = nil, options = {}, &block)
      label ||= to_s
      link_to(label, match_path(match), options, &block)
    end

    def players
      home_players = object.home_team.users
      away_players = object.away_team.users
      [home_players.length, away_players.length].max.times do |i|
        home_player = home_players[i] if i < home_players.length
        away_player = away_players[i] if i < away_players.length

        yield(home_player, away_player)
      end
    end

    def notice
      # rubocop:disable Rails/OutputSafety
      match.notice_render_cache.html_safe
      # rubocop:enable Rails/OutputSafety
    end

    def status
      return if match.confirmed?

      match.status.humanize
    end

    def forfeit_s
      forfeit_results('Home', 'Away')
    end

    def bracket_data
      common = { home: match.home_team_id, link: match_path(match) }
      return common if match.bye?

      result = common.merge(away: match.away_team_id)
      if match.confirmed?
        result[:home_score] = team_score(:home_team)
        result[:away_score] = team_score(:away_team)
      end
      result
    end

    def scheduled_at
      match.scheduled_at.strftime('%c')
    end

    private

    def score_results
      scores = present_collection(match.rounds).map(&:score_s)

      "| #{scores.join(' | ')} |"
    end

    def forfeit_results(home_s, away_s)
      case match.forfeit_by
      when 'home_team_forfeit'
        "#{home_s} forfeit"
      when 'away_team_forfeit'
        "#{away_s} forfeit"
      else
        match.forfeit_by.to_s.humanize
      end
    end

    def match_s(&block)
      round = short_round_s
      round += ':' if round.present?

      safe_join([round, match_name(&block)], ' ')
    end

    def match_name
      if bye?
        safe_join([yield(home_team), 'BYE'], ' ')
      else
        safe_join([yield(home_team), 'vs', yield(away_team)], ' ')
      end
    end

    def team_score(symbol)
      if match.no_forfeit?
        match.rounds.map(&"#{symbol}_score".to_sym).join(':')
      elsif match.send("#{symbol}_forfeit?") || match.mutual_forfeit?
        'ff'
      else
        'w'
      end
    end
  end
end
