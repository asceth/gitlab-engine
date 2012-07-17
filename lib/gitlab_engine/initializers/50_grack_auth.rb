module Grack
  class Auth < Rack::Auth::Basic

    def valid?
      # Authentication with username and password
      email, password = @auth.credentials
      user = User.find_by_email(email)
      return false unless user.try(:valid_password?, password)

      # Set GL_USER env variable
      ENV['GL_USER'] = email
      # Pass Gitolite update hook
      ENV['GL_BYPASS_UPDATE_HOOK'] = "true"

      # Need this patch because the rails mount
      @env['PATH_INFO'] = @env['REQUEST_PATH']

      # Find project by PATH_INFO from env
      if m = /^\/([\w-]+).git/.match(@env['PATH_INFO']).to_a
        return false unless project = Project.find_by_path(m.last)
      end

      # Git upload and receive
      if @env['REQUEST_METHOD'] == 'GET'
        true
      elsif @env['REQUEST_METHOD'] == 'POST'
        if @env['REQUEST_URI'].end_with?('git-upload-pack')
          return project.dev_access_for?(user)
        elsif @env['REQUEST_URI'].end_with?('git-receive-pack')
          if project.protected_branches.map(&:name).include?(current_ref)
            project.master_access_for?(user)
          else
            project.dev_access_for?(user)
          end
        else
          false
        end
      else
        false
      end
    end# valid?

    def current_ref
      if @env["HTTP_CONTENT_ENCODING"] =~ /gzip/
        input = Zlib::GzipReader.new(@request.body).string
      else
        input = @request.body.string
      end

      oldrev, newrev, ref = input.split(' ')
      /refs\/heads\/([\w-]+)/.match(ref).to_a.last
    end
  end# Auth
end# Grack
