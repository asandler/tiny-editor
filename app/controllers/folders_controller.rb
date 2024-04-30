class FoldersController < ApplicationController
    before_action :require_login
    skip_before_action :require_login, only: [:get], :raise => false

    def get
        get_folder_contents(params[:id], nil)
    end

    def edit
        @folder = find_folder(params[:id], current_user.id)
        @all_folders = Folder.where(user_id: current_user.id)
    end

    def home
        redirect_to controller: "folders", action: "get", id: current_user.root_directory_id
    end

    def new
        @parent_folder_id = params[:parent_folder_id]
    end

    def save
        # validate(params)

        if params[:id]
            update_folder(find_folder(params[:id], current_user.id), params)
        else
            update_folder(new_folder(params), params)
        end
    end

    def destroy
        Folder.destroy(params[:id])
        redirect_to home_path_url
    end

private
    def get_folder_contents id, user_id
        @folder = find_folder(id, user_id)
        @child_folders = Folder.where(parent_folder_id: id)
        @docs = Document.where(folder_id: id)

        if @folder.parent_folder_id
            @parent_folder = Folder.find(@folder.parent_folder_id)
        end
    end

    def find_folder id, user_id
        if user_id
            f = Folder.find_by(id: id, user_id: user_id)
            not_found if not f or f.user_id != current_user.id
            return f
        else
            f = Folder.find(id)
            u = User.find(f.user_id)
            not_found if not f or u.private
            return f
        end
    end

    def new_folder params
        return Folder.new(
            parent_folder_id: params[:parent_folder_id].to_i,
            user_id: current_user.id,
        )
    end

    def update_folder folder, params
        folder.name = params[:name]
        folder.parent_folder_id = params[:parent_folder_id]
        if folder.save
            redirect_to "/folders/#{folder.id}"
        else
            internal_error
        end
    end
end
