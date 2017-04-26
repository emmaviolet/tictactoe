class ApplicationController < ActionController::Base
  protect_from_forgery

  HUMAN_VERIFY = []

  helper_method :current_user
  helper_method :current_or_guest_user
  helper_method :logging_in

  rescue_from CanCan::AccessDenied do |e|
    redirect_to root_path, alert: 'Sorry, you can\'t access that page'
  end

    def current_or_guest_user
      if current_user
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
      guest_user.destroy
      session[:guest_user_id] = nil
      session[:user_id] = current_user.id
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
      destroy_old_guests
      u = User.create(:username => "guest#{Time.now.to_i}#{rand(100)}", :email => "guest_#{Time.now.to_i}#{rand(100)}", :password => "password", :password_confirmation => "password")
      u.save!(:validate => false)
      session[:guest_user_id] = u.id
      session[:user_id] = u.id
      return u
    end

    def destroy_old_guests
      guests = User.where(role: "guest")
      guests.each do |guest|
        if guest.updated_at < (Time.now - 1.day)
          guest.destroy
        end
      end
    end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end

end