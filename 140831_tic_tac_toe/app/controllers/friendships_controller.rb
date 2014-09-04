class FriendshipsController < ApplicationController
load_and_authorize_resource

  def index
    @user = Friendship.find(params[:user_id])
    @friendships = Friendship.where("user_id = #{@user.id}")
  end

  def new
    @friendship = Friendship.new
  end

  def create
   @friendship = Friendship.create user_id: current_user.id, email: params[:friendship][:email], username: params[:friendship][:username]
   friend_username_id = User.find_by_username(@friendship.username).try(:id )
   friend_email_id = User.find_by_email(@friendship.email).try(:id)
   @friendship.friend_id = friend_email_id if friend_email_id
   @friendship.friend_id = friend_username_id if friend_username_id
   @friendship.save
   respond_to do |format|
     if @friendship.persisted?
        @new_friendship = Friendship.new
        @new_friendship = Friendship.create user_id: @friendship.friend_id, friend_id: @friendship.user_id
        @new_friendship.save
        format.html { redirect_to user_path(current_user), notice: 'You and are now friends.' }
     else
       format.html { render action: "new" }
     end
   end
  end

  def show
    @friendship = Friendship.find(params[:id])
  end

  def destroy
    friendship = Friendship.find(params[:id])
    friendship.destroy
    redirect_to root_path
  end

end