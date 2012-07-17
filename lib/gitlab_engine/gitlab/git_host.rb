module GitlabEngine
  module Gitlab
    class GitHost
      def self.system
        Gitlab::Gitolite
      end

      def self.admin_uri
        GitlabEngine::Gitlab.admin_uri
      end

      def self.admin_path
        GitlabEngine::Gitlab.base_path + "/gitolite-admin.git"
      end

      def self.url_to_repo(path)
        GitlabEngine::Gitlab.config.ssh_path + "#{path}.git"
      end
    end
  end
end
