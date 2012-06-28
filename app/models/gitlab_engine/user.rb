module GitlabEngine
  module User
    def self.included(base)
      base.class_eval do

        #
        # Associations
        #
        has_many :users_projects, :dependent => :destroy
        has_many :projects, :through => :users_projects
        has_many :my_own_projects, :class_name => "Project", :foreign_key => :owner_id
        has_many :keys, :dependent => :destroy

        has_many :events, :foreign_key => :author_id

        has_many :issues, :foreign_key => :author_id, :dependent => :destroy

        has_many :notes, :foreign_key => :author_id, :dependent => :destroy

        has_many :assigned_issues, :class_name => "Issue", :foreign_key => :assignee_id, :dependent => :destroy

        has_many :merge_requests, :foreign_key => :author_id, :dependent => :destroy

        has_many :assigned_merge_requests, :class_name => "MergeRequest", :foreign_key => :assignee_id, :dependent => :destroy


        #
        # Validations
        #
        validates :projects_limit, :presence => true, :numericality => {:greater_than_or_equal_to => 0}

        validates :bio, :length => { :within => 0..255 }


        #
        # Scopes
        #
        scope :not_in_project, lambda { |project|  where("id not in (:ids)", :ids => project.users.map(&:id) ) }
        scope :admins, where(:admin =>  true)
        scope :blocked, where(:blocked =>  true)
        scope :active, where(:blocked =>  false)


        #
        # Attributes
        #
        attr_accessor :force_random_password

        attr_accessible :bio, :name, :projects_limit, :skype, :linkedin, :twitter, :dark_scheme
        attr_accessible :theme_id, :force_random_password

        alias_attribute :private_token, :authentication_token


        #
        # Callbacks
        #
        before_save :ensure_authentication_token

        before_validation :generate_password, :on => :create

      end # end class_eval

      base.send(:extend, ClassMethods)
      base.send(:include, AccountMethods)
    end


    #
    # ClassMethods
    #
    module ClassMethods
      def filter filter_name
        case filter_name
        when "admins"; self.admins
        when "blocked"; self.blocked
        when "wop"; self.without_projects
        else
          self.active
        end
      end

      def without_projects
        where('id NOT IN (SELECT DISTINCT(user_id) FROM users_projects)')
      end

      def find_for_ldap_auth(omniauth_info)
        name = omniauth_info.name.force_encoding("utf-8")
        email = omniauth_info.email.downcase

        if @user = User.find_by_email(email)
          @user
        else
          password = Devise.friendly_token[0, 8].downcase
          @user = User.create(
                              :name => name,
                              :email => email,
                              :password => password,
                              :password_confirmation => password
                              )
        end
      end

      def search(query)
        where("name like :query or email like :query", :query => "%#{query}%")
      end
    end # end ClassMethods


    #
    # AccountMethods
    #
    module AccountMethods
      def generate_password
        if self.force_random_password
          self.password = self.password_confirmation = Devise.friendly_token.first(8)
        end
      end

      def identifier
        email.gsub /[@.]/, "_"
      end

      def is_admin?
        admin
      end

      def require_ssh_key?
        keys.count == 0
      end

      def can_create_project?
        projects_limit > my_own_projects.count
      end

      def last_activity_project
        projects.first
      end

      def first_name
        name.split.first unless name.blank?
      end

      def cared_merge_requests
        MergeRequest.where("author_id = :id or assignee_id = :id", :id => self.id).opened
      end

      def project_ids
        projects.map(&:id)
      end

      # Remove user from all projects and
      # set blocked attribute to true
      def block
        users_projects.all.each do |membership|
          return false unless membership.destroy
        end

        self.blocked = true
        save
      end

      def projects_limit_percent
        return 100 if projects_limit.zero?
        (my_own_projects.count.to_f / projects_limit) * 100
      end

      def recent_push project_id = nil
        # Get push events not earlier than 2 hours ago
        scope = events.code_push.where("created_at > ?", Time.now - 2.hours)
        scope = scope.where(:project_id => project_id) if project_id

        # Take only latest one
        scope.recent.limit(1).first
      end
    end # end Account

  end
end
