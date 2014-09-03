Game.delete_all
Move.delete_all
Friendship.delete_all
User.where(role: "member").delete_all

names = ["Emma", "Shehryar", "Hisako", "Francesco", "Stef", "Luke", "Lee", "Akunor", "Abdul", "Anand", "Colin", "Habib", "Kate", "Laurence", "Michael", "Jarkyn", "Alex"]

users = []
names.each do |name|
  u = User.create username: "#{name}", email: "#{name.downcase}@wdi.io", password: "password", password_confirmation: "password"
  u.save
  users << u
end

user_ids = []
users.each do |user|
  user_ids << "#{user.id}"
end

users.each do |user|
  own_array = []
  own_array << "#{user.id}"
  friend_ids = (user_ids - own_array)

  friend_ids.each do |friend_id|
    f1 = Friendship.create user_id: "#{user.id}", friend_id: "#{friend_id}"
    f1.save
  end
end