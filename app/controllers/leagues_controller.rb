class LeaguesController < ApplicationController
  include LeaguePermissions

  before_action except: [:index, :new, :create, :medals] do
    @league = League.includes(:tiebreakers).find(params[:id])
  end

  before_action only: [:medals] do
    @league = League.includes(:tiebreakers).find(params[:league_id])
  end  

  before_action :require_user_leagues_permission, only: [:new, :create, :destroy]
  before_action :require_user_league_permission, only: [:edit, :update, :modify, :medals]
  before_action :require_league_not_hidden_or_permission, only: [:show]
  before_action :require_hidden, only: [:destroy]

  def index
    @leagues = League.search(params[:q])
                     .order(status: :asc, created_at: :desc)
                     .includes(format: :game)
    @leagues = @leagues.visible unless user_can_edit_leagues?
    @leagues = @leagues.group_by { |league| league.format.game }

    @games = @leagues.keys
  end

  def new
    @league = League.new
    @league.divisions.new
    @weekly_scheduler = @league.build_weekly_scheduler
  end

  def create
    @league = League.new(league_params)

    if @league.save
      redirect_to league_path(@league)
    else
      edit
      render :new
    end
  end

  def show
    @rosters = @league.rosters.includes(:division)
    @ordered_rosters = @league.ordered_rosters_by_division
    @divisions = @ordered_rosters.map(&:first)
    @roster = @league.roster_for(current_user) if user_signed_in?
    @personal_matches = @roster.matches.pending.ordered.reverse_order.includes(:home_team, :away_team) if @roster
    @top_div_matches = @divisions.first.matches.pending.ordered
                                 .includes(:home_team, :away_team).last(5)
    @matches = @league.matches.ordered.includes(:rounds, :home_team, :away_team)
                      .group_by(&:division)
  end

  def medals
    @rosters = @league.rosters.includes(:division)
    @ordered_rosters = @league.ordered_rosters_by_division
    @divisions = @ordered_rosters.map(&:first)
    @roster = @league.roster_for(current_user) if user_signed_in?
    @personal_matches = @roster.matches.pending.ordered.reverse_order.includes(:home_team, :away_team) if @roster
    @top_div_matches = @divisions.first.matches.pending.ordered
                                 .includes(:home_team, :away_team).last(5)
    @matches = @league.matches.ordered.includes(:rounds, :home_team, :away_team)
                      .group_by(&:division)
  end

  def edit
    @weekly_scheduler = @league.weekly_scheduler || League::Schedulers::Weekly.new
  end

  def update
    if @league.update(league_params)
      redirect_to league_path(@league)
    else
      edit
      render :edit
    end
  end

  def modify
    if @league.update(status: params.require(:status))
      redirect_to league_path(@league)
    else
      render :edit
    end
  end

  def destroy
    if @league.destroy
      redirect_to admin_path(@league)
    else
      render :edit
    end
  end

  private

  LEAGUE_PARAMS = [
    :name, :description, :format_id, :category,
    :signuppable, :hide_rosters, :roster_locked, :matches_submittable, :transfers_require_approval, :allow_disbanding,
    :forfeit_all_matches_when_roster_disbands,
    :min_players, :max_players,
    :schedule_locked, :schedule,
    :points_per_round_win, :points_per_round_draw, :points_per_round_loss,
    :points_per_match_win, :points_per_match_draw, :points_per_match_loss,
    :points_per_forfeit_win, :points_per_forfeit_draw, :points_per_forfeit_loss,
    {
      weekly_scheduler_attributes: [:id, :start_of_week, :minimum_selected, { days_indecies: [] }],
      tiebreakers_attributes:      [:id, :kind, :_destroy],
      divisions_attributes:        [:id, :name, :_destroy],
      pooled_maps_attributes:      [:id, :map_id, :_destroy],
    }
  ].freeze

  def league_params
    params.require(:league).permit(LEAGUE_PARAMS)
  end

  def require_hidden
    redirect_to league_path(@league) unless @league.hidden?
  end

  def require_user_leagues_permission
    redirect_to leagues_path unless user_can_edit_leagues?
  end

  def require_user_league_permission
    redirect_to league_path(@league) unless user_can_edit_league?
  end

  def require_league_not_hidden_or_permission
    redirect_to leagues_path unless !@league.hidden? || user_can_edit_league?
  end
end
