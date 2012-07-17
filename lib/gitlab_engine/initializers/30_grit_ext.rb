require 'grit'
require 'pygments'

Grit::Git.git_timeout = GitlabEngine::Gitlab.config.git_timeout
Grit::Git.git_max_size = GitlabEngine::Gitlab.config.git_max_size

Grit::Blob.class_eval do
  include Linguist::BlobHelper

  def data
    @data ||= @repo.git.cat_file({:p => true}, id)
    GitlabEngine::Gitlab::Encode.utf8 @data
  end
end

Grit::Diff.class_eval do
  def old_path
    GitlabEngine::Gitlab::Encode.utf8 @a_path
  end

  def new_path
    GitlabEngine::Gitlab::Encode.utf8 @b_path
  end

  def diff
    GitlabEngine::Gitlab::Encode.utf8 @diff
  end
end
