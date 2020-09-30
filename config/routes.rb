Rails.application.routes.draw do
  resources :spectacles, only: [:index, :create, :destroy]
end
