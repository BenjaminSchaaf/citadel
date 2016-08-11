class UserPresenter < ActionPresenter::Base
  presents :user

  delegate :id, to: :user
  delegate :name, to: :user
  delegate :==, to: :user

  def link(label = nil)
    label ||= user.name
    link_to(label, user_path(user))
  end

  def avatar_link
    html = ''.html_safe
    if user.avatar?
      html += image_tag(user.avatar.thumb.url, class: 'avatar center-block')
    else
      html += image_tag('thumb_missing_user.png', class: 'avatar center-block')
    end

    html
  end

  def steam_link
    link_to(user.steam_id_nice, user.steam_profile_url, target: '_blank')
  end

  def steam_id_nice
    user.steam_id_nice.html_safe
  end

  def listing(options = {})
    html = ''.html_safe
    html += image_tag(user.avatar.thumb.url) if user.avatar?
    html += link
    html += " [#{steam_link}]".html_safe unless options[:steam] == false
    #html += "#{titles(options)}".html_safe unless options[:titles] == false

    html
  end

  def titles(options = {})
    team = options[:team]

    titles = ''.html_safe
    titles += '<span class="captain">captain</span>'.html_safe if team && user.can?(:edit, team)
    titles += '<span class="admin">admin</span>'.html_safe   if user.admin?

    titles
  end

  def transfer_listing(league, options = {})
    elements = [listing(options), roster_status(league), transfer_status(league)]
    elements = elements.select { |e| !e.empty? }
    elements.join(', ').html_safe
  end

  def roster_status(league)
    transfers = league.players.where(user: user, approved: true)

    if transfers.exists?
      roster = transfers.first.roster
      "on roster '#{present(roster).link}'".html_safe
    else
      ''
    end
  end

  def transfer_status(league)
    transfers = league.transfers.where(user: user, approved: false)

    if transfers.exists?
      present(transfers.first).transfer_message
    else
      ''
    end
  end
end
