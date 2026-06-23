require "fileutils"
class ArtifactsController < ApplicationController

  def index
  end

  def download
    artifact = Artifact.find(params[:id])
    send_file artifact.storage_key,
              filename: artifact.original_filename,
              type: artifact.content_type,
              disposition: "attachment"
  end

  def show
    @artifact = Artifact.find(params[:id])
  end

  def create
    @folder = Folder.find(params[:artifact][:folder_id])
    uuid = SecureRandom.uuid
    uploaded_file = params[:artifact][:file]
    local_file_path = "#{ENV.fetch("LOCAL_FILE_LOCATION")}/#{uuid}#{uploaded_file.original_filename}"
    @artifact = Artifact.new(
      name: params[:artifact][:name],
      content_type: uploaded_file.content_type,
      storage_key: local_file_path,
      user_id: current_user.id,
      folder_id: params[:artifact][:folder_id],
      size: uploaded_file.size,
      original_filename: uploaded_file.original_filename

      )
    if @artifact.save
      FileUtils.cp(uploaded_file.tempfile, local_file_path)
    else
      @artifact = Artifact.new(folder_id: params[:folder_id])
      flash.now[:alert] = "Somthing went worng when uploading"
      render :new
    end
  end

  def new
    @artifact = Artifact.new(folder_id: params[:folder_id])
  end

  def update
  end

  def edit
  end

  def delete
  end

  def destroy
    @artifact = Artifact.find(params[:id])
    if File.exist?(@artifact.storage_key)
      File.delete(@artifact.storage_key)
    end
    @artifact.destroy
  end
end
