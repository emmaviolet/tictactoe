class GamesController < ApplicationController
load_and_authorize_resource

  def index
    @games = Game.all
  end

  def new
    @game = Game.new

    if params[:game_type] == 'pass'
      @game = Game.create
      @game.game_type = 'pass'
      @game.player_1_id = current_user.id
      @game.player_2_id = current_user.id
      @game.result = 'active'
      @game.save
      redirect_to game_path(@game)
    end

    if params[:game_type] == 'computer'
      @game = Game.create
      @game.game_type = 'computer'
      @game.result = 'active'
      @game.save
      redirect_to games_new_first_user_path(id: @game.id)
    end

    if params[:game_type] == 'friend'
      @game = Game.create
      @game.game_type = 'friend'
      @game.result = 'active'
      @game.save
      redirect_to games_new_friend_path(id: @game.id)
    end
  end

  def friend
    @game = Game.find(params[:id])
  end

  def friend_update
    id = params[:game].values.first.to_i
    @game = Game.find(id)
    @game.player_2_id = params[:player_2_id].values.first.to_i
    @game.save
    redirect_to games_new_first_user_path(id: @game.id)
  end

  def first_user
    @game = Game.find(params[:id])
  end

  def first_user_update
    id = params[:game].values.first.to_i
    @game = Game.find(id)
    case @game.game_type
    when "friend"
      if params[:player].values.first.to_s == "Me"
        @game.player_1_id = current_user.id
      end
      if params[:player].values.first.to_s == "Them"
        @game.player_1_id = @game.player_2_id
        @game.player_2_id = current_user.id
      end
    when "computer"
      if params[:player].values.first.to_s == "Me"
        @game.player_1_id = current_user.id
        @game.player_2_id = 100
      end
      if params[:player].values.first.to_s == "Computer"
        @game.player_1_id = 100
        @game.player_2_id = current_user.id
      end
    end
    @game.save
    redirect_to @game
  end


  def create
    @game = Game.find(params[:id])
    case @game.type
    when 'friend'
      if (params[:id]) == "Me"
        @game.player_1_id = current_user.id
        @game.player_2_id = 3
      end
      if (params[:id]) == "Them"
        @game.player_1_id = 3
        @game.player_2_id = current_user.id
      end
    end

  end

  def show
    @game = Game.find(params[:id])
  end

  def destroy
    game = Game.find(params[:id])
    game.destroy
    redirect_to games_path
  end

  def edit
    @game = Game.find(params[:id])
  end

  def update
    @game = Game.find(params[:id])
    @game.update_attributes(params[:game])
      redirect_to @game
  end

end