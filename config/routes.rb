# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root to: 'quiz#index'

  resources :quiz do
    post :update_progress, to: 'quiz#update_progress'
    post :add_guest, to: 'quiz#add_guest'
    get :get_progress, to: 'quiz#get_progress'

    resources :question do
      post 'submit_answer', to: 'question#submit_answer'
    end
  end

  resources :series

  get :join, to: 'quiz#join'

  get :health, to: 'health#index'
end
