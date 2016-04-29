Rails.application.routes.draw do
  mount Upmin::Engine => '/admin'

  devise_for :users, :controllers => { registrations: 'registrations', sessions: "sessions" }

  devise_scope :user do
    post    '/users/sign_up'  =>  'registrations#create'
    post    'users/sign_in'   =>  'sessions#create'
    delete  'users/sign_out'  =>  'sessions#destroy'
    post    'account'         => 'registrations#edit'
    get     'profile'         => 'registrations#profile'
    post    'users/award_badge' => 'users#award_badge'
    get     'users/cancel_account' => 'registrations#cancel_account'
  end

  namespace :api do
#    namespace :v1 do
    devise_scope :user do
      post    'users/sign_in'  => 'sessions#create'
      delete  'users/sign_out' => 'sessions#destroy'
      post    'users/sign_up'  => 'registrations#create'
      put     'account'        => 'registrations#update'
      get     'users/profile'  => 'registrations#profile'
      put     'users'          => 'users#update'
      get     'users/settings' => 'registrations#settings'
      put     'users/settings' => 'registrations#update_settings'
      post    'register_device' => 'users#register_device'
      get     'notifications'  => 'users#notifications'
      post    'notifications/:id' => 'users#read_notification'
      delete  'notifications' => 'users#all_notifications_read'
      get     'users/award_badge' => 'users#get_award_badge'
      post    'users/award_badge' => 'users#post_award_badge'
      get     'users/cancel' => 'registrations#cancel_account'
      post     'users/password' => 'passwords#create'
    end
    post 'events/create' => 'events#create'
    get 'events/pending_claims' => 'events#pending_claims'
    get 'events/pending_events' => 'events#pending_events'
    get 'events/my_events' => 'events#my_events'
    get 'events/confirmed' => 'events#confirmed'
    get 'claims/pending_claims' => 'claims#pending_claims'
    post 'claims/teacher_confirm' => 'claims#teacher_confirm'#, :via => [:post], :as => 'teacher_confirm_claim'
    get 'schools/make_mine/:id' => 'schools#make_mine'#, :via => [:post]
    post 'send_message/:id'  => 'users#send_message'
    get 'users/:user_id/badges' => 'users#show_badges'
    get 'users/:user_id/badges/:user_badge_id' => 'users#get_badge'
    delete 'events/:id/cancel' => 'events#cancel'
    delete 'claims/:id/reject' => 'claims#reject'
    delete 'claims/:id/cancel' => 'claims#cancel'
    resources :sessions
    resources :users
    resources :schools
    resources :events
    resources :claims
    match 'events/claim_event' => 'events#claim_event', :via => [:post], :as => 'claim_event'
 
#  end
  end

  resources :users
  resources :schools do
    member do
      get :near_me
    end
  end
  resources :events
  resources :claims
  resources :locations
  resources :static_pages

  root to: 'static_pages#home'
  get     'choose' => 'schools#choose'
  get     'help'    => 'static_pages#help'
  get     'about'   => 'static_pages#about'
  get     'contact' => 'static_pages#contact'
  get     'signin'  => 'static_pages#signin'
  get     'privacy_policy' => 'static_pages#privacy_policy'
  get     'getting_started' => 'static_pages#getting_started'
  delete  'cancel'  => 'events#cancel'
  get     'invalid_event'  => 'static_pages#invalid_event'
  get     'write_message/:id' => 'users#write_message'
  post    'write_message/:id'  => 'users#send_message'
  get     'tags/:tag',  to: 'events#index', as: :tag
  get     'users/:tag',  to: 'users#index'
  get     'users/:user_id/badges' => 'users#show_badges'
  get     'users/:user_id/badges/:user_badge_id' => 'users#get_badge'
  get    'notifications/:id' => 'users#read_notification'
  post    'make_mine', to: 'schools#make_mine'
  #get     'users/edit'      => 'registrations#edit'
  get     'android' => 'static_pages#android'
  # TODO Make these https secure
  post    'email_responses/bounce' => 'email_responses#bounce'
  post    'email_responses/complaint' => 'email_responses#complaint'
  # Schools
  get     'near_me' => 'schools#near_me', via: [:get], as: 'schools_near_me'

  # Handle Claims
  delete  'claims/:id/reject' => 'claims#reject'
  delete  'claims/:id/cancel' => 'claims#cancel'
  match   'claims/:id/teacher_confirm' => 'claims#teacher_confirm', :via => [:post], :as => 'teacher_confirm_claim'
  match   'claims/:id/speaker_confirm' => 'claims#speaker_confirm', :via => [:post], :as => 'speaker_confirm_claim'
  match   'events/claim_event' => 'events#claim_event', :via => [:post], :as => 'claim_event'
  match   'schools/claim_school' => 'schools#claim_school', :via => [:post], :as => 'claim_school'
  #match '/contacts', to: 'contacts#new',
  #resources "contacts", only: [:new, :create]
end
