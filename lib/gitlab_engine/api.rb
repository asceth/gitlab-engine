require 'grape'

path = File.dirname(File.expand_path(__FILE__))
Dir["#{path}/api/*.rb"].each {|file| require file}

module GitlabEngine
  class API < ::Grape::API
    VERSION = 'v2'
    version VERSION, :using => :path

    rescue_from ActiveRecord::RecordNotFound do
      rack_response({'message' => '404 Not found'}.to_json, 404)
    end

    format :json
    error_format :json
    helpers GitlabEngine::APIHelpers

    mount Users
    mount Projects
  end
end
