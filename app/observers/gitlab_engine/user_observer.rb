class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notify.new_user_email(user.id, 'nope').deliver
  end
end
