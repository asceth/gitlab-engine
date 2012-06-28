require 'spec_helper'

describe Project do
  describe "Associations" do
    it { should have_many(:users) }
    it { should have_many(:protected_branches).dependent(:destroy) }
    it { should have_many(:events).dependent(:destroy) }
    it { should have_many(:wikis).dependent(:destroy) }
    it { should have_many(:merge_requests).dependent(:destroy) }
    it { should have_many(:users_projects).dependent(:destroy) }
    it { should have_many(:issues).dependent(:destroy) }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_many(:snippets).dependent(:destroy) }
    it { should have_many(:web_hooks).dependent(:destroy) }
    it { should have_many(:deploy_keys).dependent(:destroy) }
  end

  describe "Validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:code) }
  end

  describe "Respond to" do
    it { should respond_to(:repository_writers) }
    it { should respond_to(:add_access) }
    it { should respond_to(:reset_access) }
    it { should respond_to(:update_repository) }
    it { should respond_to(:destroy_repository) }
    it { should respond_to(:public?) }
    it { should respond_to(:private?) }
    it { should respond_to(:url_to_repo) }
    it { should respond_to(:path_to_repo) }
    it { should respond_to(:valid_repo?) }
    it { should respond_to(:repo_exists?) }
    it { should respond_to(:repo) }
    it { should respond_to(:tags) }
    it { should respond_to(:commit) }
    it { should respond_to(:commits_between) }
  end

  it "should not allow 'gitolite-admin' as repo name" do
    should allow_value("blah").for(:path)
    should_not allow_value("gitolite-admin").for(:path)
  end

  it "should return valid url to repo" do
    project = Project.new(:path => "somewhere")
    project.url_to_repo.should == "git@localhost:somewhere.git"
  end

  it "should return path to repo" do
    project = Project.new(:path => "somewhere")
    project.path_to_repo.should == File.join(Rails.root, "tmp", "tests", "somewhere")
  end

  it "returns the full web URL for this repo" do
    project = Project.new(:code => "somewhere")
    project.web_url.should == "#{GIT_HOST['host']}/somewhere"
  end

  describe :valid_repo? do
    it "should be valid repo" do
      project = Factory :project
      project.valid_repo?.should be_true
    end

    it "should be invalid repo" do
      project = Project.new(:name => "ok_name", :path => "/INVALID_PATH/", :code => "NEOK")
      project.valid_repo?.should be_false
    end
  end

  describe "last_activity" do
    let(:project) { Factory :project }

    before do
      @issue = Factory :issue, :project => project
    end

    it { project.last_activity.should == Event.last }
    it { project.last_activity_date.to_s.should == Event.last.created_at.to_s }
  end

  describe "fresh commits" do
    let(:project) { Factory :project }

    it { project.fresh_commits(3).count.should == 3 }
    it { project.fresh_commits.first.id.should == "bcf03b5de6c33f3869ef70d68cf06e679d1d7f9a" }
    it { project.fresh_commits.last.id.should == "f403da73f5e62794a0447aca879360494b08f678" }
  end

  describe "commits_between" do
    let(:project) { Factory :project }

    subject do
      commits = project.commits_between("3a4b4fb4cde7809f033822a171b9feae19d41fff",
                                        "8470d70da67355c9c009e4401746b1d5410af2e3")
      commits.map { |c| c.id }
    end

    it { should have(3).elements }
    it { should include("f0f14c8eaba69ebddd766498a9d0b0e79becd633") }
    it { should_not include("bcf03b5de6c33f3869ef70d68cf06e679d1d7f9a") }
  end

  describe "Git methods" do
    let(:project) { Factory :project }

    describe :repo do
      it "should return valid repo" do
        project.repo.should be_kind_of(Grit::Repo)
      end

      it "should return nil" do
        lambda { Project.new(:path => "invalid").repo }.should raise_error(Grit::NoSuchPathError)
      end

      it "should return nil" do
        lambda { Project.new.repo }.should raise_error(TypeError)
      end
    end

    describe :commit do
      it "should return first head commit if without params" do
        project.commit.id.should == project.repo.commits.first.id
      end

      it "should return valid commit" do
        project.commit(ValidCommit::ID).should be_valid_commit
      end

      it "should return nil" do
        project.commit("+123_4532530XYZ").should be_nil
      end
    end

    describe :tree do
      before do
        @commit = project.commit(ValidCommit::ID)
      end

      it "should raise error w/o arguments" do
        lambda { project.tree }.should raise_error
      end

      it "should return root tree for commit" do
        tree = project.tree(@commit)
        tree.contents.size.should == ValidCommit::FILES_COUNT
        tree.contents.map(&:name).should == ValidCommit::FILES
      end

      it "should return root tree for commit with correct path" do
        tree = project.tree(@commit, ValidCommit::C_FILE_PATH)
        tree.contents.map(&:name).should == ValidCommit::C_FILES
      end

      it "should return root tree for commit with incorrect path" do
        project.tree(@commit, "invalid_path").should be_nil
      end
    end
  end

  describe :update_merge_requests do 
    let(:project) { Factory :project }

    before do
      @merge_request = Factory :merge_request,
        :project => project,
        :merged => false,
        :closed => false
      @key = Factory :key, :user_id => project.owner.id
    end

    it "should close merge request if last commit from source branch was pushed to target branch" do
      @merge_request.reloaded_commits
      @merge_request.last_commit.id.should == "bcf03b5de6c33f3869ef70d68cf06e679d1d7f9a"
      project.update_merge_requests("8716fc78f3c65bbf7bcf7b574febd583bc5d2812", "bcf03b5de6c33f3869ef70d68cf06e679d1d7f9a", "refs/heads/stable", @key.user)
      @merge_request.reload
      @merge_request.merged.should be_true
      @merge_request.closed.should be_true
    end

    it "should update merge request commits with new one if pushed to source branch" do 
      @merge_request.last_commit.should == nil
      project.update_merge_requests("8716fc78f3c65bbf7bcf7b574febd583bc5d2812", "bcf03b5de6c33f3869ef70d68cf06e679d1d7f9a", "refs/heads/master", @key.user)
      @merge_request.reload
      @merge_request.last_commit.id.should == "bcf03b5de6c33f3869ef70d68cf06e679d1d7f9a"
    end
  end
end
# == Schema Information
#
# Table name: projects
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  path                   :string(255)
#  description            :text
#  created_at             :datetime
#  updated_at             :datetime
#  private_flag           :boolean         default(TRUE), not null
#  code                   :string(255)
#  owner_id               :integer
#  default_branch         :string(255)     default("master"), not null
#  issues_enabled         :boolean         default(TRUE), not null
#  wall_enabled           :boolean         default(TRUE), not null
#  merge_requests_enabled :boolean         default(TRUE), not null
#  wiki_enabled           :boolean         default(TRUE), not null
#

