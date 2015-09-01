Rails.application.routes.draw do
  resources :orders, only: [] do
    collection do
      post :update_address
    end
  end
end
