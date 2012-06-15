GitlabEngine::Engine.routes.draw do
  #
  # Search
  #
  get 'search' => "search#show"

  #
  # Help
  #
  get 'help' => 'help#index'
  get 'help/permissions' => 'help#permissions'
  get 'help/workflow' => 'help#workflow'
  get 'help/web_hooks' => 'help#web_hooks'

  #
  # Profile Area
  #
  get "profile/password", :to => "profile#password"
  put "profile/password", :to => "profile#password_update"
  get "profile/token", :to => "profile#token"
  put "profile/reset_private_token", :to => "profile#reset_private_token"
  get "profile", :to => "profile#show"
  get "profile/design", :to => "profile#design"
  put "profile/update", :to => "profile#update"

  #
  # Admin Area
  #
  namespace :admin do
    resources :users do
      member do
        put :team_update
        put :block
        put :unblock
      end
    end
    resources :projects, :constraints => { :id => /[^\/]+/ } do
      member do
        get :team
        put :team_update
      end
    end
    resources :team_members, :only => [:edit, :update, :destroy]
    get 'emails', :to => 'mailer#preview'
    get 'mailer/preview_note'
    get 'mailer/preview_user_new'
    get 'mailer/preview_issue_new'
    root :to => "dashboard#index"
  end

  get "errors/githost"

  #
  # Profile Area
  #
  resources :keys

  #
  # Project Area
  #
  resources :projects, :constraints => { :id => /[^\/]+/ } do
    member do
      get "wall"
      get "graph"
      get "files"
    end

    resources :wikis, :only => [:show, :edit, :destroy, :create] do
      member do
        get "history"
      end
    end

    resource :repository do
      member do
        get "branches"
        get "tags"
        get "archive"
      end
    end

    resources :deploy_keys
    resources :protected_branches, :only => [:index, :create, :destroy]

    resources :refs, :only => [], :path => "/" do
      collection do
        get "switch"
      end

      member do
        get "tree", :constraints => { :id => /[a-zA-Z.\/0-9_\-]+/ }
        get "blob",
          :constraints => {
            :id => /[a-zA-Z.0-9\/_\-]+/,
            :path => /.*/
          }


        # tree viewer
        get "tree/:path" => "refs#tree",
          :as => :tree_file,
          :constraints => {
            :id => /[a-zA-Z.0-9\/_\-]+/,
            :path => /.*/
          }

        # blame
        get "blame/:path" => "refs#blame",
          :as => :blame_file,
          :constraints => {
            :id => /[a-zA-Z.0-9\/_\-]+/,
            :path => /.*/
          }
      end
    end

    resources :merge_requests do
      member do
        get :diffs
        get :automerge
        get :automerge_check
      end

      collection do
        get :branch_from
        get :branch_to
      end
    end

    resources :snippets do
      member do
        get "raw"
      end
    end

    resources :hooks, :only => [:index, :create, :destroy] do
      member do
        get :test
      end
    end
    resources :commits do
      collection do
        get :compare
      end
    end
    resources :team_members
    resources :milestones
    resources :issues do
      collection do
        post  :sort
        get   :search
      end
    end
    resources :notes, :only => [:index, :create, :destroy]
  end

  #
  # Hook Service
  #
  resources :post_receives, :only => [:create]

  #
  # Dashboard Area
  #
  get "dashboard", :to => "dashboard#index"
  get "dashboard/issues", :to => "dashboard#issues"
  get "dashboard/merge_requests", :to => "dashboard#merge_requests"

  root :to => "dashboard#index"
end
