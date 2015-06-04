Rails.application.routes.draw do
  mount Upmin::Engine => '/admin'

  devise_for :users, :controllers => { registrations: 'registrations' }

  devise_scope :user do
    post    '/users/sign_up'  =>  'registrations#create'
    post    'users/sign_in'   =>  'sessions#create'
    get     'profile'      => 'registrations#edit'
  end

  resources :users
  resources :schools
  resources :events
  resources :claims
  resources :locations
  resources :static_pages

  root to: 'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get    'signin'  => 'static_pages#signin'
  get    'invalid_event'  => 'static_pages#invalid_event'
  get 'tags/:tag',  to: 'events#index', as: :tag
  get 'users/:tag',  to: 'users#index'
  post 'make_mine', to: 'schools#make_mine'
  #get     'users/edit'      => 'registrations#edit'

  match 'claims/:id/teacher_confirm' => 'claims#teacher_confirm', :via => [:post], :as => 'teacher_confirm_claim'
  match 'claims/:id/speaker_confirm' => 'claims#speaker_confirm', :via => [:post], :as => 'speaker_confirm_claim'
  match 'events/claim_event' => 'events#claim_event', :via => [:post], :as => 'claim_event'
 
  #match '/contacts', to: 'contacts#new',
  #resources "contacts", only: [:new, :create]
end
