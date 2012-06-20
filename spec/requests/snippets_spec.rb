require 'spec_helper'

describe "Snippets" do
  let(:project) { Factory :project }

  before do
    login_as :user
    project.add_access(@user, :read, :write)
  end

  describe "GET /snippets" do
    before do
      @snippet = Factory :snippet,
        :author => @user,
        :project => project

      visit project_snippets_path(project)
    end

    subject { page }

    it { should have_content(@snippet.title[0..10]) }
    it { should have_content(@snippet.project.name) }

    describe "Destroy" do
      before do
        # admin access to remove snippet
        @user.users_projects.destroy_all
        project.add_access(@user, :read, :write, :admin)
        visit edit_project_snippet_path(project, @snippet)
      end

      it "should remove entry" do
        expect {
          click_link "destroy_snippet_#{@snippet.id}"
        }.to change { Snippet.count }.by(-1)
      end
    end
  end

  describe "New snippet" do
    before do
      visit project_snippets_path(project)
      click_link "New Snippet"
    end

    it "should open new snippet popup" do
      page.current_path.should == new_project_snippet_path(project)
    end

    describe "fill in" do
      before do
        fill_in "snippet_title", :with => "login function"
        fill_in "snippet_file_name", :with => "test.rb"
        fill_in "snippet_content", :with => "def login; end"
      end

      it { expect { click_button "Save" }.to change {Snippet.count}.by(1) }

      it "should add new snippet to table" do
        click_button "Save"
        page.current_path.should == project_snippet_path(project, Snippet.last)
        page.should have_content "login function"
        page.should have_content "test.rb"
      end
    end
  end

  describe "Edit snippet" do
    before do
      @snippet = Factory :snippet,
        :author => @user,
        :project => project
      visit project_snippet_path(project, @snippet)
      click_link "Edit"
    end

    it "should open edit page" do
      page.current_path.should == edit_project_snippet_path(project, @snippet)
    end

    describe "fill in" do
      before do
        fill_in "snippet_title", :with => "login function"
        fill_in "snippet_file_name", :with => "test.rb"
        fill_in "snippet_content", :with => "def login; end"
      end

      it { expect { click_button "Save" }.to_not change {Snippet.count} }

      it "should update snippet fields" do
        click_button "Save"

        page.current_path.should == project_snippet_path(project, @snippet)
        page.should have_content "login function"
        page.should have_content "test.rb"
      end
    end
  end
end
