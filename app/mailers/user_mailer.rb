class UserMailer < ActionMailer::Base

  def registration_confirmation(user)
    @user = user
    mail(from: "admin@tictactoe.io", to: user.email, subject: 'You\'re registered')
  end

  def user_invite(email, name, user)
    @email = email
    @name = name
    @user = User.find(user)
    mail(from: "#{@user.username}@tictactoe.io", to: @email, subject: "#{@user.username} thinks you should join Tic Tac Toe")
  end

end
