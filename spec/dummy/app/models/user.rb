class User < ActiveRecord::Base
  include GitlabEngine::User


  #
  # Devise
  #
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  #
  # Attributes
  #
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
