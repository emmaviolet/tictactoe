class Ability
  include CanCan::Ability

  user = :current_user

  def initialize(user)
    user ||= User.new

    can :manage, :all

  end

end