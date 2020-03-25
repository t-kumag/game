Rails.application.routes.draw do
  # scope 'api/v1' do
  #   use_doorkeeper do
  #     # enable only :token controller
  #     skip_controllers :authorizations, :token_info, :applications, :authorized_applications
  #   end
  # end

  # System Info
  get 'maintenance/info', to: 'maintenance#info'

  # get "/", to: static("index.html")
  namespace :api, format: 'json' do
    namespace :v1 do
      get 'categories', :to => 'categories#index'
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'

      resources :notices, :path => '/notices', :only => [:index, :create] do
        collection do
          get 'unread-total-count'
          put 'all-read'
        end
      end
      resources :activities, :path => '/activities', :only => [:index] do
      end

      # 個人用
      namespace :user do
        resources :bank_accounts, :path => '/bank-accounts', :only => [:index, :update, :destroy] do
          resources :bank_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :card_accounts, :path => '/card-accounts', :only => [:index, :update, :destroy] do
          resources :card_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :emoney_accounts, :path => '/emoney-accounts', :only => [:index, :update, :destroy] do
          resources :emoney_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        get 'icon', to: 'icon#index'
        post 'icon', to: 'icon#create'
        put 'icon', to: 'icon#update'

        get 'card-accounts-summary', :to => 'card_accounts#summary'
        get 'bank-accounts-summary', :to => 'bank_accounts#summary'
        get 'emoney-accounts-summary', :to => 'emoney_accounts#summary'

        get 'pl-summary', :to => 'pl#summary'
        get 'bs-summary', :to => 'bs#summary'
        get 'pl-categories', :to => 'pl#categories'
        get 'pl-grouped-categories', :to => 'pl#grouped_categories'
        get 'transactions', :to => 'transactions#index'
        get 'grouped-transactions', :to => 'transactions#grouped_transactions'

        resources :user_manually_created_transactions, path: '/user-manually-created-transactions', only: [:index, :show, :create, :update, :destroy]

        resources :profiles, only: [:create]
        get 'profiles', :to => 'profiles#show'
        put 'profiles', :to => 'profiles#update'

      end

      # 共有用
      namespace :group do
        resources :bank_accounts, :path => '/bank-accounts', :only => [:index] do
          resources :bank_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :card_accounts, :path => '/card-accounts', :only => [:index] do
          resources :card_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :emoney_accounts, :path => '/emoney-accounts', :only => [:index] do
          resources :emoney_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :goals, path: '/goals' do
          resources :goal_settings, path: '/goal-settings', on: :member, only: [:create, :show, :update] do
          end
        end
        post 'goals/:id/add_money', :to => 'goals#add_money'

        get 'card-accounts-summary', :to => 'card_accounts#summary'
        get 'bank-accounts-summary', :to => 'bank_accounts#summary'
        get 'emoney-accounts-summary', :to => 'emoney_accounts#summary'

        get 'pl-summary', :to => 'pl#summary'
        get 'bs-summary', :to => 'bs#summary'
        get 'pl-categories', :to => 'pl#categories'
        get 'pl-grouped-categories', :to => 'pl#grouped_categories'
        get 'transactions', :to => 'transactions#index'
        get 'grouped-transactions', :to => 'transactions#grouped_transactions'

        get 'goal-graph/:id', :to => 'goals#graph'

        get 'profiles', :to => 'profiles#show'
        resources :user_manually_created_transactions, path: '/user-manually-created-transactions', only: [:index]
      end

      resources :pairing_requests, :path => '/pairing-requests', :only => [] do
        collection do
          get :generate_pairing_token
          post :receive_pairing_request
          post :confirm_pairing_request
        end
      end
      delete 'pairing-requests', :to => 'pairing_requests#destroy'

      resources :users, only: [:create]
      post 'users/change_password_request', to: 'users#change_password_request'
      post 'users/change_password', to: 'users#change_password'
      delete 'users', :to => 'users#destroy'

      get 'invite-url', :to => 'groups#invite_url'
      get 'user/at-url', :to => 'users#at_url'
      get 'user/at-sync', :to => 'users#at_sync'
      # sidekiqテスト用 at_sync_test
      get 'user/at-sync-test', :to => 'users#at_sync_test'

      get 'user/at-token', :to => 'users#at_token'
      get 'user/activate', :to => 'users#activate'
      post 'user/resend', to: 'users#resend'

      resources :budget_questions, path: '/budget-questions', only: [:create]

      if Rails.env.development?
        get 'sample1/report', to: 'sample1#report'
      end
    end

    namespace :v2 do
      resources :activities, :path => '/activities', :only => [:index] do
      end

      get 'user/status', :to => 'users#status'

      # 個人用
      namespace :user do
        resources :bank_accounts, path: '/bank-accounts' do
          resources :bank_transactions, path: '/transactions', on: :member, only: [:index] do
          end
        end

        resources :card_accounts, path: '/card-accounts' do
          resources :card_transactions, path: '/transactions', on: :member, only: [:index] do
          end
        end

        resources :emoney_accounts, path: '/emoney-accounts'do
          resources :emoney_transactions, path: '/transactions', on: :member, only: [:index] do
          end
        end

        resources :wallets, path: '/wallets' do
          resources :wallet_transactions, path: '/transactions', on: :member, only: [:index, :show]
        end

        put 'pl-settings', :to => 'pl_settings#update'
        get 'pl-settings', :to => 'pl_settings#show'

        resources :stock_accounts, path: '/stock-accounts' do
          resources :asset_products, path: '/asset-products', on: :member, only: [:index]
        end

      end

      # 共有用
      namespace :group do
        resources :bank_accounts, path: '/bank-accounts' do
          resources :bank_transactions, path: '/transactions', on: :member, only: [:index] do
          end
        end

        resources :card_accounts, path: '/card-accounts' do
          resources :card_transactions, path: '/transactions', on: :member, only: [:index] do
          end
        end

        resources :emoney_accounts, path: '/emoney-accounts' do
          resources :emoney_transactions, path: '/transactions', on: :member, only: [:index] do
          end
        end

        resources :wallets, path: '/wallets' do
          resources :wallet_transactions, path: '/transactions', on: :member, only: [:index, :show]
        end

        resources :stock_accounts, path: '/stock-accounts' do
          resources :asset_products, path: '/asset-products', on: :member, only: [:index]
        end

        get 'summary-transactions', :to => 'transactions#summary_transactions'
      end

      resources :payment_methods, path: '/payment_methods', only: [:index]
    end
  end
end
