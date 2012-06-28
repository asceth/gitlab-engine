module GitlabEngine
  class ProjectObserver < ActiveRecord::Observer
    observe :project

    def after_save(project)
      project.update_repository
    end

    def after_destroy(project)
      project.destroy_repository
    end
  end
end
