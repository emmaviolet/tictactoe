class Friendship < ActiveRecord::Base
  attr_accessible :friend_id, :user_id, :email, :username

  belongs_to :friend, class_name: "User", :foreign_key => 'friend_id'
  belongs_to :user
  
  validate :email_or_username

  def email_or_username
    unless (User.find_by_username(self.username) != nil || self.username == nil) || (User.find_by_email(self.email) != nil || self.email == nil)
          errors.add(:unrecognised_value, "Sorry, we don't recognise that email or username.")
    end
  end

end
