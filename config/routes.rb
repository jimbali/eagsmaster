Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  root to: "quiz#index"

  resources :quiz do
    get :progress, to: 'quiz#progress'

    resources :question do
      post 'submit_answer', to: 'question#submit_answer'
    end
  end

  get :join, to: 'quiz#join'

  post :update_points, to: 'quiz#update_points'

  get :health, to: 'health#index'
end
