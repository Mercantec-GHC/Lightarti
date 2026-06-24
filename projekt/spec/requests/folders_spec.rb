require "rails_helper"

RSpec.describe "Folders", type: :request do
  let(:user) { User.create!(user_name: "kim", password: "password") }

  before do
    post session_path,
      params: {
        user: {
          user_name: user.user_name,
          password: "password"
        }
      }
  end

  describe "GET /folders" do
    it "returns success" do
      get folders_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /folders" do
    it "creates a folder and gives current user admin permission" do
      expect {
        post folders_path, params: {
          folder: {
            name: "Test folder"
          }
        }
      }.to change(Folder, :count).by(1)
        .and change(FolderPermission, :count).by(1)

      folder = Folder.last

      expect(folder.name).to eq("Test folder")
      expect(folder.folder_permissions.last.user).to eq(user)
      expect(folder.folder_permissions.last.role).to eq("admin")
      expect(response).to redirect_to(folders_path)
    end
  end

  describe "GET /folders/:id" do
    it "shows a folder" do
      folder = Folder.create!(name: "t2est")
      get folder_path(folder, format: :turbo_stream)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /folders/:id" do
    it "deletes a folder" do
      folder = Folder.create!(name: "Delete me")

      expect {
        delete folder_path(folder)
      }.to change(Folder, :count).by(-1)
    end
  end
end