TicTacToe::Application.routes.draw do
 
 root to: 'games#index'

 resources :games
 resources :users
 resources :sessions
 resources :moves

 get 'games/new/friend', to: 'games#friend'
 put 'games/new/friend', to: 'games#friend_update'

 get 'games/new/first_user', to: 'games#first_user'
 put 'games/new/first_user', to: 'games#first_user_update'

 get 'logout', to: 'sessions#destroy'

end
