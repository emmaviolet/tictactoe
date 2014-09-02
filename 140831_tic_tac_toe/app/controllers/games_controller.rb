class GamesController < ApplicationController
load_and_authorize_resource

  def index
    @games = Game.all
  end

  def new
    @game = Game.new
    @game = Game.create

    if params[:game_type] == 'pass'
      @game.game_type = 'pass'
      @game.player_1_id = current_user.id
      @game.player_2_id = current_user.id
      @game.save
      redirect_to game_path(@game)
    end

    if params[:game_type] == 'computer'
      @game.game_type = 'computer'
      @game.player_2_id = 3
      @game.save
      redirect_to games_new_first_user_path(id: @game.id)
    end

    if params[:game_type] == 'friend'
      @game.game_type = 'friend'
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
    case params[:player].values.first.to_s
    when "Me"
      @game.player_1_id = current_user.id
    when "Them"
      @game.player_1_id = @game.player_2_id
      @game.player_2_id = current_user.id
    when "Computer"
      @game.player_1_id = 3
      @game.player_2_id = current_user.id
      @game.save
      @game.computer_move
    end
    @game.save
    redirect_to @game
  end

  def show
    @game = Game.find(params[:id])
  end

  def destroy
    game = Game.find(params[:id])
    game.destroy
    redirect_to games_path
  end

end