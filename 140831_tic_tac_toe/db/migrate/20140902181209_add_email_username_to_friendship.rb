class AddEmailUsernameToFriendship < ActiveRecord::Migration
  def change
    add_column :friendships, :email, :string
    add_column :friendships, :username, :string
  end
end
