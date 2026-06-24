require "rails_helper"

RSpec.describe "Artifacts", type: :request do
  let(:user) { User.create!(user_name: "kim", password: "password") }
  let(:folder) { Folder.create!(name: "Test folder") }

  before do
    post session_path, params: {
      user: {
        user_name: user.user_name,
        password: "password"
      }
    }
  end

  describe "GET /artifacts/new" do
    it "returns success" do
      get new_artifact_path, params: { folder_id: folder.id, format: :turbo_stream }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /artifacts/:id" do
    it "shows an artifact" do
      artifact = Artifact.create!(
        name: "Test file",
        content_type: "text/plain",
        storage_key: Rails.root.join("tmp/test_file.txt").to_s,
        user_id: user.id,
        folder_id: folder.id,
        size: 12,
        original_filename: "test.txt"
      )

      get artifact_path(artifact, format: :turbo_stream)

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /artifacts" do
    it "creates an artifact and copies the uploaded file" do
      upload_dir = Rails.root.join("tmp/uploads")
      FileUtils.mkdir_p(upload_dir)

      allow(ENV).to receive(:fetch)
        .with("LOCAL_FILE_LOCATION")
        .and_return(upload_dir.to_s)

      file = fixture_file_upload(
        Rails.root.join("spec/fixtures/files/test.txt"),
        "text/plain"
      )

      expect {
        post artifacts_path, params: {
          artifact: {
            name: "My test file",
            folder_id: folder.id,
            file: file
          }
        }
      }.to change(Artifact, :count).by(1)

      artifact = Artifact.last

      expect(artifact.name).to eq("My test file")
      expect(artifact.folder_id).to eq(folder.id)
      expect(artifact.user_id).to eq(user.id)
      expect(artifact.content_type).to eq("text/plain")
      expect(artifact.original_filename).to eq("test.txt")
      expect(File.exist?(artifact.storage_key)).to be true
    ensure
      FileUtils.rm_rf(upload_dir)
    end
  end

  describe "GET /artifacts/:id/download" do
    it "downloads the artifact file" do
      file_path = Rails.root.join("tmp/download_test.txt")
      File.write(file_path, "Hello from test")

      artifact = Artifact.create!(
        name: "Download file",
        content_type: "text/plain",
        storage_key: file_path.to_s,
        user_id: user.id,
        folder_id: folder.id,
        size: File.size(file_path),
        original_filename: "download_test.txt"
      )

      get download_artifacts_path(artifact)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to include("text/plain")
      expect(response.headers["Content-Disposition"]).to include("attachment")
      expect(response.headers["Content-Disposition"]).to include("download_test.txt")
    ensure
      File.delete(file_path) if file_path && File.exist?(file_path)
    end
  end

  describe "DELETE /artifacts/:id" do
    it "deletes the artifact and the stored file" do
      file_path = Rails.root.join("tmp/delete_test.txt")
      File.write(file_path, "Delete me")

      artifact = Artifact.create!(
        name: "Delete file",
        content_type: "text/plain",
        storage_key: file_path.to_s,
        user_id: user.id,
        folder_id: folder.id,
        size: File.size(file_path),
        original_filename: "delete_test.txt"
      )

      expect {
        delete artifact_path(artifact)
      }.to change(Artifact, :count).by(-1)

      expect(File.exist?(file_path)).to be false
    end
  end
end