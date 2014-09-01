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
    @game = Game.find(params[:id])
    @game.update_attributes(params[:game])
      redirect_to @game
    # @game.player_2_id = params[:player_2_id]
    # redirect_to @game
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