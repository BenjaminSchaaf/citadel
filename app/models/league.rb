require 'search'

class League < ApplicationRecord
  include MarkdownRenderCaching

  belongs_to :format

  has_many :divisions, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :divisions, allow_destroy: true
  has_many :tiebreakers, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :tiebreakers, allow_destroy: true
  has_many :pooled_maps, inverse_of: :league, dependent: :destroy
  accepts_nested_attributes_for :pooled_maps, allow_destroy: true

  has_many :rosters,           through: :divisions, class_name: 'Roster',
                               counter_cache: :rosters_count
  has_many :transfers,         through: :rosters,   class_name: 'Roster::Transfer'
  has_many :players,           through: :rosters,   class_name: 'Roster::Player'
  has_many :transfer_requests, through: :rosters,   class_name: 'Roster::TransferRequest'
  has_many :matches,           through: :divisions, class_name: 'Match'

  has_many :titles, class_name: 'User::Title', dependent: :destroy

  enum status: { hidden: 0, running: 1, completed: 2 }

  validates :name,        presence: true, length: { in: 1..64 }
  validates :description, presence: true
  caches_markdown_render_for :description, escaped: false

  validates :category, length: { in: 0..64, allow_nil: false }

  validates :signuppable,                              inclusion: { in: [true, false] }
  validates :roster_locked,                            inclusion: { in: [true, false] }
  validates :matches_submittable,                      inclusion: { in: [true, false] }
  validates :transfers_require_approval,               inclusion: { in: [true, false] }
  validates :allow_disbanding,                         inclusion: { in: [true, false] }
  validates :schedule_locked,                          inclusion: { in: [true, false] }
  validates :forfeit_all_matches_when_roster_disbands, inclusion: { in: [true, false] }
  validates :hide_rosters,                             inclusion: { in: [true, false] }
  validates :allow_rescheduling,                       inclusion: { in: [true, false] }

  validates :min_players, presence: true, numericality: { greater_than: 0 }
  validates :max_players, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :points_per_round_win,  presence: true
  validates :points_per_round_draw, presence: true
  validates :points_per_round_loss, presence: true
  validates :points_per_match_win,  presence: true
  validates :points_per_match_draw, presence: true
  validates :points_per_match_loss, presence: true
  validates :points_per_forfeit_win,  presence: true
  validates :points_per_forfeit_draw, presence: true
  validates :points_per_forfeit_loss, presence: true

  # Scheduling
  enum schedule: { manual: 0, weeklies: 1 }
  has_one :weekly_scheduler, inverse_of: :league, class_name: 'League::Schedulers::Weekly',
                             dependent: :destroy
  accepts_nested_attributes_for :weekly_scheduler

  validate :validate_players_range
  validate :validate_has_scheduler

  after_initialize :set_defaults, unless: :persisted?
  before_save :update_query_cache
  after_save :trigger_scores_update!

  scope :visible, -> { where.not(status: League.statuses[:hidden]) }

  scope :search, (lambda do |query|
    return all if query.blank?

    query = Search.transform_query(query)

    where('(query_name_cache <-> ?) < 0.9', query)
      .order(sanitize_sql_for_order([Arel.sql('query_name_cache <-> ?'), query]))
  end)

  def entered?(user)
    players.exists?(user: user)
  end

  def roster_for(user)
    players.find_by(user: user)&.roster
  end

  def ordered_rosters_by_division
    return divisions.map { |div| [div, []] } if rosters.approved.empty?

    rosters.includes(:division).order(:division_id).approved.ordered.group_by(&:division)
  end

  def valid_roster_size?(size)
    min_players <= size && (size <= max_players || max_players.zero?)
  end

  def map_pool
    if pooled_maps.empty?
      Map.all
    else
      Map.where(id: pooled_maps.select(:map_id))
    end
  end

  def scheduler
    case schedule
    when 'manual'
      nil
    when 'weeklies'
      weekly_scheduler
    else
      throw
    end
  end

  def point_multipliers
    [points_per_round_win,   points_per_round_draw,   points_per_round_loss,
     points_per_match_win,   points_per_match_draw,   points_per_match_loss,
     points_per_forfeit_win, points_per_forfeit_draw, points_per_forfeit_loss]
  end

  def reset_query_cache!
    update_query_cache
    save!
  end

  def trigger_scores_update!
    divisions.find_each { |div| Leagues::Rosters::ScoreUpdatingService.call(self, div) }
  end

  private

  def update_query_cache
    self.query_name_cache = Search.transform_query(name)
  end

  def validate_players_range
    if min_players.present? && max_players.present? &&
       min_players > max_players && max_players != 0
      errors.add(:min_players, "Can't be greater than maximum players")
    end
  end

  def validate_has_scheduler
    errors.add(:schedule, 'Missing scheduler') unless schedule == 'manual' || scheduler.present?
  end

  def set_defaults
    self.status ||= :private
    self.signuppable ||= true
    self.roster_locked = false if roster_locked.blank?

    self.min_players ||= 6
    self.max_players ||= 16

    self.schedule ||= :manual
  end
end
