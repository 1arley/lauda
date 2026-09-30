Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root 'dashboard#index'

  get 'convites/aceitar' => 'invitations#accept', as: :accept_invitation
  patch 'convites/aceitar' => 'invitations#accept_registration'
  resources :invitations, only: %i[new create]

  resources :patients

  resources :assessments do
    member do
      post :finalize
    end

    resources :instrument_applications, path: 'instruments' do
      member do
        get :edit_answers
        patch :update_answers
        get :score
        post :compute
        get :results
      end
    end

    resources :reports, only: %i[new create show edit update] do
      member do
        post :finalize
        post :export_pdf
      end
    end
  end

  resources :report_templates, except: :show

  resources :snippets, only: %i[index new create edit update destroy]

  resources :export_jobs, only: %i[index show]

  get 'up' => 'rails/health#show', as: :rails_health_check
end
