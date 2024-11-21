module Leagues
  class MatchesController < ApplicationController
    include MatchesCommon

    before_action only: [:index, :new, :create, :generate, :create_round] do
      @league = League.find(params[:league_id])
    end
    before_action except: [:index, :new, :create, :generate, :create_round] do
      @match = League::Match.includes(home_team: { division: :league })
                            .find(params[:id])
      @league = @match.league
    end

    before_action :require_user_league_permission, only: [:new, :create, :generate, :create_round,
                                                          :edit, :update, :destroy]
    before_action :require_user_either_teams, only: [:submit, :confirm]
    before_action :require_user_can_report_scores, only: [:submit, :forfeit]
    before_action :require_match_not_bye, only: [:submit, :confirm, :forfeit]
    before_action :require_match_not_forfeit, only: [:forfeit]

    def index
      @divisions = @league.divisions.includes(matches: [:home_team, :away_team, :rounds])
                          .order(:id)
                          .merge(League::Match.ordered)
                          .references(:matches)
      @matches = @divisions.map { |div| [div, div.matches] }.to_h
    end

    def new
      @match = League::Match.new
      @match.rounds.new
      @division = @league.divisions.first
    end

    def create
      @division = @league.divisions.find(params[:division_id])
      @match = Matches::CreationService.call(match_params)

      if @match.persisted?
        redirect_to match_path(@match)
      else
        @match.reset_results
        render :new
      end
    end

    def generate
      @match = League::Match.new
      @match.rounds.new
      @division = @league.divisions.first
      @tournament_system = :swiss
      @swiss_tournament = { pairer: :dutch, pair_options: { allow_duplicates: false, push_byes_to: :bottom_half } }
      @round_robin_tournament = {}
      @single_elimination_tournament = { teams_limit: 0, starting_round: 0 }
      @double_elimination_tournament = { teams_limit: 0, starting_round: 0 }
      @page_playoffs_tournament = { starting_round: 0, bronze_match: false }
    end

    def create_round
      @division = @league.divisions.find(params.delete(:division_id))
      fetch_tournament_params

      @match = Matches::GenerationService.call(@division, create_round_params, @tournament_system, tournament_params)

      if @match
        @match.reset_results
        render :generate
      else
        redirect_to league_matches_path(@league)
      end
    end

    def show
      match_show_includes

      @comm = League::Match::Comm.new(match: @match)
      @edit = League::Match::ScheduleEdit.new(match: @match)
    end

    def edit
    end

    def update
      if @match.update(match_params)
        redirect_to match_path(@match)
      else
        render :edit
      end
    end

    def submit
      if @match.update(report_scores_params)
        redirect_to match_path(@match)
      else
        @match.status = :pending
        show
        render :show
      end
    end

    def confirm
      if user_can_confirm_score? || user_can_edit_league?
        @match.confirm_scores(params[:confirm] == 'true')
        show
        render :show
      else
        redirect_to match_path(@match)
      end
    end

    def forfeit
      if user_can_home_team?
        @match.update!(forfeit_by: :home_team_forfeit)
      else
        @match.update!(forfeit_by: :away_team_forfeit)
      end

      show
      render :show
    end

    def destroy
      if @match.destroy
        redirect_to league_path(@league)
      else
        render :edit
      end
    end

    private

    def report_scores_params
      if user_can_edit_league?
        params.require(:match)
              .permit(:status, :forfeit_by,
                      rounds_attributes: [:id, :home_team_score, :away_team_score])
      elsif user_can_either_teams?
        report_scores_by_team_params
      end
    end

    def report_scores_by_team_params
      attrs = params.require(:match)
                    .permit(rounds_attributes: [:id, :home_team_score, :away_team_score])

      attrs[:status] = if user_can_home_team?
                         :submitted_by_home_team
                       else
                         :submitted_by_away_team
                       end

      attrs
    end

    def match_params
      params.require(:match).permit(:home_team_id, :away_team_id, :has_winner, :allow_round_draws,
                                    :round_name, :round_number, :notice, :scheduled_at,
                                    pick_bans_attributes: [:id, :_destroy, :kind, :team, :deferrable],
                                    rounds_attributes:    [:id, :_destroy, :map_id])
    end

    def create_round_params
      params.require(:match).permit(:division_id, :generate_kind, :has_winner, :allow_round_draws,
                                    :round_name, :round_number, :notice, :scheduled_at,
                                    pick_bans_attributes: [:id, :_destroy, :kind, :team, :deferrable],
                                    rounds_attributes:    [:id, :_destroy, :map_id])
    end

    def fetch_tournament_params
      @tournament_system             = params.delete(:tournament_system).to_sym
      @swiss_tournament              = swiss_tournament_params
      @round_robin_tournament        = round_robin_tournament_params
      @single_elimination_tournament = single_elimination_tournament_params
      @double_elimination_tournament = double_elimination_tournament_params
      @page_playoffs_tournament      = page_playoffs_tournament_params
    end

    def tournament_params
      case @tournament_system
      when :swiss              then swiss_tournament_params
      when :round_robin        then round_robin_tournament_params
      when :single_elimination then single_elimination_tournament_params
      when :double_elimination then double_elimination_tournament_params
      when :page_playoffs      then page_playoffs_tournament_params
      else
        raise 'Invalid tournament system'
      end
    end

    def swiss_tournament_params
      params.require(:swiss_tournament).permit(:pairer, :allow_unconfirmed_matches,
                                               pair_options: [:allow_duplicates, :push_byes_to])
    end

    def round_robin_tournament_params
      {}
    end

    def single_elimination_tournament_params
      params.require(:single_elimination_tournament).permit(:teams_limit, :starting_round)
    end

    def double_elimination_tournament_params
      params.require(:double_elimination_tournament).permit(:teams_limit, :starting_round)
    end

    def page_playoffs_tournament_params
      params.require(:page_playoffs_tournament).permit(:starting_round, :bronze_match)
    end

    def require_user_can_report_scores
      redirect_to match_path(@match) unless user_can_submit_team_score?
    end

    def require_user_league_permission
      redirect_to league_path(@league) unless user_can_edit_league?
    end

    def require_user_either_teams
      redirect_to match_path(@match) unless user_can_either_teams?
    end

    def require_match_not_bye
      redirect_to match_path(@match) if @match.bye?
    end

    def require_match_not_forfeit
      redirect_to match_path(@match) unless @match.no_forfeit?
    end
  end
end
