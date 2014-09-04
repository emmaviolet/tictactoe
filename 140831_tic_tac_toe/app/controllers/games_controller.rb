class GamesController < ApplicationController
  load_and_authorize_resource

  def index
    @games = Game.all
  end

  def new
    @game = Game.new
  
    if params[:game_type] == 'pass'
      @game = Game.create game_type: 'pass', player_1_id: current_or_guest_user.id, player_2_id: current_or_guest_user.id
      @game.save
      redirect_to games_new_board_size_path(id: @game.id)
    end

    if params[:game_type] == 'computer'
      @game = Game.create game_type: 'computer', player_1_id: current_or_guest_user.id
      @game.player_2_id = User.find_by_username("Computer").id
      @game.save
      redirect_to games_new_computer_path(id: @game.id)
    end

    if params[:game_type] == 'friend'
      @game = Game.create game_type: 'friend'
      @game.save
      redirect_to games_new_friend_path(id: @game.id, user: current_or_guest_user)
    end
  end

  def friend
    @game = Game.find(params[:id])
  end

  def friend_update
    @game = Game.find(params[:game].values.first.to_i)
    @game.player_2_id = params[:player_2_id].values.first.to_i
    @game.save
    redirect_to games_new_board_size_path(id: @game.id)
  end

  def computer
    @game = Game.find(params[:id])
  end

  def computer_update
    @game = Game.find(params[:game].values.first.to_i)
    @game.difficulty = params[:difficulty].values.first.to_i
    @game.save
    redirect_to games_new_board_size_path(id: @game.id)
  end

  def first_user
    @game = Game.find(params[:id])
  end

  def first_user_update
    @game = Game.find(params[:game].values.first.to_i)
    case params[:player].values.first.to_s
    when "Me"
      @game.player_1_id = current_or_guest_user.id
    when "Them"
      @game.player_1_id = @game.player_2_id
      @game.player_2_id = current_or_guest_user.id
    when "Computer"
      @game.player_1_id = User.find_by_username("Computer").id
      @game.player_2_id = current_or_guest_user.id
      @game.save
      @game.computer_move
    end
    @game.save
    redirect_to @game
  end

  def board_size
    @game = Game.find(params[:id])
  end

  def board_size_update
    @game = Game.find(params[:game].values.first.to_i)
    @game.board_size = params[:board_size].values.first.to_i
    @game.save
    redirect_to @game if @game.game_type == "pass"
    redirect_to games_new_first_user_path(id: @game.id) if @game.game_type != "pass"
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