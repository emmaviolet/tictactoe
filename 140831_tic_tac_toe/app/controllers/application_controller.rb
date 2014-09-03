class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  rescue_from CanCan::AccessDenied do |e|
    redirect_to root_path, alert: 'Sorry, you can\'t access that page'
  end

  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end

  # def current_or_guest_user
  #   if current_user
  #     if session[:guest_user_id]
  #       logging_in
  #       guest_user.destroy
  #       session[:guest_user_id] = nil
  #     end
  #     current_user
  #   else
  #     guest_user
  #   end
  # end

  #   # find guest_user object associated with the current session,
  #   # creating one as needed
  #   def guest_user
  #     # Cache the value the first time it's gotten.
  #     @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  #   rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
  #    session[:guest_user_id] = nil
  #    guest_user
  #  end

  #  private

  #   # called (once) when the user logs in, insert any code your application needs
  #   # to hand off from guest_user to current_user.
  #   def logging_in
  #     # For example:
  #     # guest_comments = guest_user.comments.all
  #     # guest_comments.each do |comment|
  #       # comment.user_id = current_user.id
  #       # comment.save!
  #     # end
  #   end

  #   def create_guest_user
  #     u = User.create(:name => "guest", :email => "guest_#{Time.now.to_i}#{rand(100)}@example.com")
  #     u.save!(:validate => false)
  #     session[:guest_user_id] = u.id
  #     u
  #   end

  # end

end