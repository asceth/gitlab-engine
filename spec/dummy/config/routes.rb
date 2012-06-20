Rails.application.routes.draw do

  mount GitlabEngine::Engine => '/'

  devise_for :users
end
