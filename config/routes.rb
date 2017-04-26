TicTacToe::Application.routes.draw do
 
 root to: 'games#index'

 resources :users
 resources :sessions
 resources :moves
 resources :friendships
 resources :games

 get 'games/new/friend', to: 'games#friend'
 put 'games/new/friend', to: 'games#friend_update'

 get 'games/new/computer', to: 'games#computer'
 put 'games/new/computer', to: 'games#computer_update'

 get 'games/new/first_user', to: 'games#first_user'
 put 'games/new/first_user', to: 'games#first_user_update'

 get 'games/new/board_size', to: 'games#board_size'
 put 'games/new/board_size', to: 'games#board_size_update'

 get 'users/friendships/:id', to: 'users#friendships'
 get 'logout', to: 'sessions#destroy'
 
end
