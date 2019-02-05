Rails.application.routes.draw do
  # scope 'api/v1' do
  #   use_doorkeeper do
  #     # enable only :token controller
  #     skip_controllers :authorizations, :token_info, :applications, :authorized_applications
  #   end
  # end

  # get "/", to: static("index.html")
  namespace :api, format: 'json'  do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'
      namespace :user do
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
    
        get 'card-accounts-summary', :to => 'card_accounts#summary'
        get 'bank-accounts-summary', :to => 'bank_accounts#summary'
        get 'emoney-accounts-summary', :to => 'emoney_accounts#summary'
    
        namespace :pl do
          get 'summary', :to => 'pl#summary'
          get 'transactions', :to => 'pl#transactions'
        end
      end
    
      resources :user_manually_created_transactions, :only => [:index, :show, :create, :update] do        
      end

      get 'invite-url', :to => 'groups#invite_url'
      get 'user/at-url', :to => 'users#at_url'
      get 'user/at-sync', :to => 'users#at_sync'

      namespace :family do
        resources :savings_goals, :path => '/goals' do
        end
      # groups/:id/goals/:id/summary
      # groups/:id/goals/:id/settings
      # groups/:id/goals/:id/savings-amounts
      # groups/:id/goals/:id/settings/:id/
    
      end
    end
  end


end
