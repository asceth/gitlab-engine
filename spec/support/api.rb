def api_prefix
  "/api/#{GitlabEngine::API::VERSION}"
end

def json_response
  JSON.parse(response.body)
end
