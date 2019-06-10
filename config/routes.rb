Rails.application.routes.draw do
  # scope 'api/v1' do
  #   use_doorkeeper do
  #     # enable only :token controller
  #     skip_controllers :authorizations, :token_info, :applications, :authorized_applications
  #   end
  # end

  # get "/", to: static("index.html")
  namespace :api, format: 'json' do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'
      delete 'auth/logout', to: 'auth#logout'

      resources :notices, :path => '/notices', :only => [:index, :create, :show] do
      end

      # 個人用
      namespace :user do
        resources :bank_accounts, :path => '/bank-accounts', :only => [:index, :destroy] do
          resources :bank_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :card_accounts, :path => '/card-accounts', :only => [:index, :destroy] do
          resources :card_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :emoney_accounts, :path => '/emoney-accounts', :only => [:index, :destroy] do
          resources :emoney_transactions, :path => '/transactions', on: :member, :only => [:index, :show, :update] do
          end
        end

        resources :goals, path: '/goals'

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

        # TODO goal_settingsの更新
        resources :goals, path: '/goals'

        get 'card-accounts-summary', :to => 'card_accounts#summary'
        get 'bank-accounts-summary', :to => 'bank_accounts#summary'
        get 'emoney-accounts-summary', :to => 'emoney_accounts#summary'

        get 'pl-summary', :to => 'pl#summary'
        get 'bs-summary', :to => 'bs#summary'
        get 'pl-categories', :to => 'pl#categories'
        get 'pl-grouped-categories', :to => 'pl#grouped_categories'
        get 'transactions', :to => 'transactions#index'
        get 'grouped-transactions', :to => 'transactions#grouped_transactions'
      end


      resources :pairing_requests, :path => '/pairing-requests', :only => [] do
        collection do
          get :generate_pairing_token
          post :receive_pairing_request
          post :confirm_pairing_request
        end
      end

      resources :users, only: [:create]

      get 'invite-url', :to => 'groups#invite_url'
      get 'user/at-url', :to => 'users#at_url'
      get 'user/at-sync', :to => 'users#at_sync'
      get 'user/at-token', :to => 'users#at_token'

      resources :budget_questions, path: '/budget-questions', only: [:create]
    end
  end


end
