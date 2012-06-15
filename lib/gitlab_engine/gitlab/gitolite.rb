require 'gitolite'
require 'timeout'
require 'fileutils'

module GitlabEngine
  module Gitlab
    class Gitolite
      class AccessDenied < StandardError; end

      def self.update_project(path, project)
        self.new.configure { |git| git.update_project(path, project) }
      end

      def self.destroy_project(project)
        self.new.configure { |git| git.destroy_project(project) }
      end

      def pull
        bare = Grit::Repo.new(Gitlab::GitHost.admin_path)

        # find tmp dir and create
        @local_dir = File.dirname(bare.git.create_tempfile("gitlab", true))
        @path = File.join(@local_dir, "gitolite-admin")
        git = Grit::Git.new(@path)

        unless git.exists?
          # clone
          bare.git.clone({}, bare.git.git_dir, git.git_dir)
        end

        @repo = Grit::Repo.new(@path)
        @repo.git.pull({})
      end

      def push
        @repo.git.add({:A => true})
        @repo.git.commit({:a => true, :m => "Gitlab"})
        @repo.git.push({})
      end

      def configure
        Timeout::timeout(20) do
          pull
          yield(self)
          push
        end
      rescue Exception => ex
        Gitlab::Logger.error(ex.message)
        raise Gitolite::AccessDenied.new("gitolite timeout")
      end

      def destroy_project(project)
        return
        FileUtils.rm_rf(project.path_to_repo)

        ga_repo = ::Gitolite::GitoliteAdmin.new(@path)
        conf = ga_repo.config
        conf.rm_repo(project.path)
        ga_repo.save
      end

      #update or create
      def update_keys(user, key)
        @repo.git.fs_write("keydir/#{user}.pub", key.gsub(/\n/,''))
      end

      def delete_key(user)
        key_file = "keydir/#{user}.pub"
        @repo.git.fs_delete(key_file)
        @repo.git.remove(key_file)
      end

      # update or create
      def update_project(repo_name, project)
        return
        ga_repo = ::Gitolite::GitoliteAdmin.new(@path)
        conf = ga_repo.config
        repo = update_project_config(project, conf)
        conf.add_repo(repo, true)

        ga_repo.save
      end

      # Updates many projects and uses project.path as the repo path
      # An order of magnitude faster than update_project
      def update_projects(projects)
        ga_repo = ::Gitolite::GitoliteAdmin.new(@path)
        conf = ga_repo.config

        projects.each do |project|
          repo = update_project_config(project, conf)
          conf.add_repo(repo, true)
        end

        ga_repo.save
      end

      def update_project_config(project, conf)
        repo_name = project.path

        repo = if conf.has_repo?(repo_name)
                 conf.get_repo(repo_name)
               else
                 ::Gitolite::Config::Repo.new(repo_name)
               end

        name_readers = project.repository_readers
        name_writers = project.repository_writers
        name_masters = project.repository_masters

        pr_br = project.protected_branches.map(&:name).join(" ")

        repo.clean_permissions

        # Deny access to protected branches for writers
        unless name_writers.blank? || pr_br.blank?
          repo.add_permission("-", pr_br, name_writers)
        end

        # Add read permissions
        repo.add_permission("R", "", name_readers) unless name_readers.blank?

        # Add write permissions
        repo.add_permission("RW+", "", name_writers) unless name_writers.blank?
        repo.add_permission("RW+", "", name_masters) unless name_masters.blank?

        repo
      end

      def admin_all_repo
        ga_repo = ::Gitolite::GitoliteAdmin.new(File.join(@local_dir,'gitolite'))
        conf = ga_repo.config
        owner_name = ""

        # Read gitolite-admin user
        #
        begin
          repo = conf.get_repo("gitolite-admin")
          owner_name = repo.permissions[0]["RW+"][""][0]
          raise StandardError if owner_name.blank?
        rescue => ex
          puts "Cant determine gitolite-admin owner".red
          raise StandardError
        end

        # @ALL repos premission for gitolite owner
        repo_name = "@all"
        repo = if conf.has_repo?(repo_name)
                 conf.get_repo(repo_name)
               else
                 ::Gitolite::Config::Repo.new(repo_name)
               end

        repo.add_permission("RW+", "", owner_name)
        conf.add_repo(repo, true)
        ga_repo.save
      end
    end
  end
end
