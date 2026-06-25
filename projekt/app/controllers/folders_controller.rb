class FoldersController < ApplicationController
  def index
    if current_user
      @folders = current_user.folders.where(parent_id: nil).sort_by(&:name)
      puts @folders.count
    else
      @folders = []
    end
  end

  def delete
  end

  def destroy
    @folder = Folder.find(params[:id])
    @folder.destroy!
  end

  def create
    @folder = Folder.new(folder_params)
    if @folder.save
      @folder.folder_permissions.create!(user: current_user, role: "admin")
      if @folder.parent
        @dom_folder = @folder.parent
        @folder_open = params[:folder][:folder_open]
      else
        @root_folder = true
        @folders = current_user.folders.where(parent_id: nil).sort_by(&:name)
      end
    else
      flash.now[:alert] = "There was a problem creating the folder."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @folder = Folder.new
    @parent = Folder.find(params[:parent_id]) if params[:parent_id]
    @dom_id = params[:dom_id] || "folder-list"
    @folder_open = params[:folder_open]
  end

  def show
    @folder = Folder.find(params[:id])
    @rootfolder = @folder.parent_id.nil?
    @sub_folders = @folder.children.sort_by(&:name)
    @artifacts = Artifact.where(folder_id: @folder.id)
  end
  
  def close
    @folder = Folder.find(params[:id])
    @rootfolder = @folder.parent_id.nil?
  end

  private

  def folder_params
    params.require(:folder).permit(:name, :parent_id)
  end
end
