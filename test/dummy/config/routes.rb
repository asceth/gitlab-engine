Rails.application.routes.draw do

  mount GitlabEngine::Engine => "/gitlab-engine"
end
