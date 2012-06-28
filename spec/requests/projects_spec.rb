require 'spec_helper'

describe "Projects" do
  before { login_as :user }

  describe "GET /projects/new" do
    before do
      visit root_path
      click_link "New Project"
    end

    it "should be correct path" do
      current_path.should == new_project_path
    end

    it "should have labels for new project" do
      page.should have_content("Project name is")
    end
  end

  describe "POST /projects" do
    before do
      visit new_project_path
      fill_in 'project_name', :with => 'NewProject'
      fill_in 'project_code', :with => 'NPR'
      fill_in 'project_path', :with => 'newproject'
      expect { click_button "Create project" }.to change { Project.count }.by(1)
      @project = Project.last
    end

    it "should be correct path" do
      current_path.should == project_path(@project)
    end

    it "should show project" do
      page.should have_content(@project.name)
      page.should have_content(@project.path)
      page.should have_content(@project.description)
    end

    it "should init repo instructions" do
      page.should have_content("git remote")
      page.should have_content(@project.url_to_repo)
    end
  end

  describe "GET /projects/show" do
    before do
      @project = Factory :project, :owner => @user
      @project.add_access(@user, :read)

      visit project_path(@project)
    end

    it "should be correct path" do
      current_path.should == project_path(@project)
    end
  end

  describe "GET /projects/graph" do
    before do
      @project = Factory :project
      @project.add_access(@user, :read)

      visit graph_project_path(@project)
    end

    it "should be correct path" do
      current_path.should == graph_project_path(@project)
    end

    it "should have as as team member" do
      page.should have_content("master")
    end
  end

  describe "GET /projects/team" do
    before do
      @project = Factory :project
      @project.add_access(@user, :read)

      visit project_team_members_path(@project,
                                      :path => ValidCommit::BLOB_FILE_PATH,
                                      :commit_id => ValidCommit::ID)
    end

    it "should be correct path" do
      current_path.should == project_team_members_path(@project)
    end

    it "should have as as team member" do
      page.should have_content(@user.name)
    end
  end

  describe "GET /projects/:id/edit" do
    before do
      @project = Factory :project
      @project.add_access(@user, :admin, :read)

      visit edit_project_path(@project)
    end

    it "should be correct path" do
      current_path.should == edit_project_path(@project)
    end

    it "should have labels for new project" do
      page.should have_content("Project name is")
      page.should have_content("Advanced settings:")
      page.should have_content("Features:")
    end
  end

  describe "PUT /projects/:id" do
    before do
      @project = Factory :project, :owner => @user
      @project.add_access(@user, :admin, :read)

      visit edit_project_path(@project)

      fill_in 'project_name', :with => 'Awesome'
      fill_in 'project_path', :with => 'gitlabhq'
      click_button "Save"
      @project = @project.reload
    end

    it "should be correct path" do
      current_path.should == edit_project_path(@project)
    end

    it "should show project" do
      page.should have_content("Awesome")
    end
  end

  describe "DELETE /projects/:id" do
    before do
      @project = Factory :project
      @project.add_access(@user, :read, :admin)
      visit edit_project_path(@project)
    end

    it "should be correct path" do
      expect { click_link "Remove" }.to change {Project.count}.by(-1)
    end
  end
end
