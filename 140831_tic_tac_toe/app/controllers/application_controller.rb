class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  helper_method :current_or_guest_user
  helper_method :logging_in

  rescue_from CanCan::AccessDenied do |e|
    redirect_to root_path, alert: 'Sorry, you can\'t access that page'
  end

    def current_or_guest_user
      if current_user
        if session[:guest_user_id]
          logging_in
          guest_user.destroy
          session[:guest_user_id] = nil
          session[:user_id] = current_user.id
        end
        current_user
      else
        guest_user
      end
    end

    private
    def guest_user
      @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

    rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user
   end

    def logging_in
      guest_user.games.each do |game|
        if game.player_1_id == guest_user.id
          game.player_1_id = current_user.id
        end
        if game.player_2_id == guest_user.id
          game.player_2_id = current_user.id
        end
        game.save
      end
    end

    def create_guest_user
      u = User.create(:username => "guest#{Time.now.to_i}#{rand(100)}", :email => "guest_#{Time.now.to_i}#{rand(100)}", :password => "password", :password_confirmation => "password")
      u.save!(:validate => false)
      session[:guest_user_id] = u.id
      session[:user_id] = u.id
      return u
    end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end

end