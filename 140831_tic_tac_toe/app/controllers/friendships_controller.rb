class FriendshipsController < ApplicationController
load_and_authorize_resource

  def new
    @friendship = Friendship.new
    @friendship = Friendship.create user_id: current_user.id
    @friendship.save
  end

  def create
   
  end

  def update
    @friendship = Friendship.find(params[:id])
    @username = params[:friendship][:username]
    @email = params[:friendship][:email]
    if @username != nil
      @friend = User.find_by_username("#{@username}")
    end
    if @username == nil && @email != nil
      @friend = User.find_by_email("#{@email}")
    end
    @friendship.friend_id = @friend.id
    @friendship.save
    @new_friendship = Friendship.new
    @new_friendship = Friendship.create user_id: @friendship.friend_id, friend_id: @friendship.user_id
    @new_friendship.save
    redirect_to user_path(current_user)
  end

end