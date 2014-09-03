class Ability
  include CanCan::Ability

  user = :current_or_guest_user

  def initialize(user)
    user ||= User.new

    if user.role? :admin
      can :manage, :all
    end

    if user.role? :member
      can :manage, Friendship do |friendship_to_check|
        friendship_to_check.try(:user_id) == user.id || friendship_to_check.try(:user_id) == nil
      end
    end
    can :manage, :all
    can :create, User
    can :create, Game
    can :manage, User do |user_to_check|
      user_to_check.try(:created_at) == nil || user_to_check.try(:created_at) <= Time.now
    end

    can :manage, Game do |game_to_check|
      game_to_check.try(:player_1_id) == user.id || game_to_check.try(:player_2_id) == user.id || game_to_check.try(:player_1_id) == nil || game_to_check.try(:player_2_id) == nil
    end

    can :manage, Move do |move_to_check|
      game_to_check = move_to_check.try(:game)
      game_to_check.try(:player_1_id) == user.id || game_to_check.try(:player_2_id) == user.id || game_to_check.try(:player_1_id) == nil || game_to_check.try(:player_2_id) == nil
    end
  end
end