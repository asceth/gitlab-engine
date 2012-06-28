module GitlabEngine
  class UserObserver < ActiveRecord::Observer
    observe :user

    def after_create(user)
      Notify.new_user_email(user.id, 'nope').deliver
    end
  end
end
