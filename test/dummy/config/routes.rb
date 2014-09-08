Rails.application.routes.draw do
  get 'widgets/reload' => 'widgets#reload'
  resources :widgets
  root 'widgets#index'
end