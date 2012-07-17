def api_prefix
  "/api/#{GitlabEngine::Gitlab::API::VERSION}"
end

def json_response
  JSON.parse(response.body)
end
