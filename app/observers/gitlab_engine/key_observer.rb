module GitlabEngine
  class KeyObserver < ActiveRecord::Observer
    observe :key

    def after_save(key)
      key.update_repository
    end

    def after_destroy(key)
      key.repository_delete_key
    end
  end
end
