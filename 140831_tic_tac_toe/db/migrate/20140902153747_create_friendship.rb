class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendship do |t|
      t.string :friend_id
      t.string :user_id

      t.timestamps
    end
  end
end
