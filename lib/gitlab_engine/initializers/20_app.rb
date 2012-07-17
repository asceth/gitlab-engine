module GitlabEngine
  module Gitlab
    path = File.dirname(File.expand_path(__FILE__))
    Version = File.read("#{path}/../../../VERSION")
    Revision = `git log --pretty=format:'%h' -n 1`

    def self.config
      Settings
    end
  end
end
