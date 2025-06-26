Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # root
  root 'api/home#index'

  # API routes
  namespace :api do
    namespace :v1 do
      resources :accounts
      resources :companies
      resources :customers
      resources :vendors
      resources :accounting_classes
      resources :journal_entries
      resources :reports, only: [] do
        collection do
          get 'balance_sheet'
          get 'general_ledger'
          get 'profit_loss'
          get 'balance_sheet_excel'
          get 'general_ledger_excel'
          get 'profit_loss_excel'
        end
      end 
    end
  end

  # Frontend routes
  resources :accounts, only: [:index, :show, :create]
  resources :companies, only: [:index, :show, :create]
  resources :customers, only: [:index, :show, :create]
  resources :vendors, only: [:index, :show, :create]
  resources :accounting_classes, only: [:index, :show, :create]
  resources :journal_entries, only: [:index, :show, :create]
  resources :reports, only: [:index]


end
