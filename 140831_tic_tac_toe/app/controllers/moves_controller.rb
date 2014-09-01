class MovesController < ApplicationController
load_and_authorize_resource

  def index
    @moves = Move.all
  end

  def new
    @move = Move.new
    @game = Game.find(params[:game_id])
    @move = Move.create game_id: @game.id, current_user: current_user.id
    @move.square = params[:square]
    @move.player_number = params[:player_number]
    @move.save

    @game.result = @game.is_over?
    @game.save

    redirect_to game_path(@move.game_id)
  end

  def create
    @move = Move.find(params[:id])
    @move.update_attributes(params[:move])
  end

  def show
    @move = Move.find(params[:id])
  end

  def destroy
    move = Move.find(params[:id])
    move.destroy
    redirect_to moves_path
  end

  def edit
    @move = Move.find(params[:id])
  end

  def update
    @move = Move.find(params[:id])
    @move.update_attributes(params[:move])
      redirect_to @move
  end

end