class FoldersController < ApplicationController
    before_action :require_login
    skip_before_action :require_login, only: [:get], :raise => false

    def get
        get_folder_contents(params[:id])
    end

    def edit
        @folder = find_user_folder(params[:id])
        bad_request if not @folder.parent_folder_id
        @all_folders = Folder.where(user_id: current_user.id)
    end

    def home
        redirect_to controller: "folders", action: "get", id: current_user.root_folder_id
    end

    def new
        @parent_folder_id = params[:parent_folder_id]
    end

    def save
        # params = validate(params)

        if params[:id]
            update_folder(find_user_folder(params[:id]), params)
        else
            update_folder(new_folder(params), params)
        end
    end

    def destroy
        Folder.destroy(params[:id])
        redirect_to home_path_url
    end

private
    def get_folder_contents id
        @folder = find_folder(id)
        @child_folders = Folder.where(parent_folder_id: id)
        @docs = Document.where(folder_id: id)

        if @folder.parent_folder_id
            @parent_folder = Folder.find(@folder.parent_folder_id)
        end
    end

    def find_user_folder id
        not_found if not current_user
        Folder.find_by(id: id, user_id: current_user.id) || not_found
    end

    def find_folder id
        f = Folder.find(id) || not_found
        u = User.find(f.user_id) || not_found

        if current_user and current_user.id == f.user_id
            return f
        end

        not_found if u.private

        return f
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

    def validate_params params
        begin
            Integer(params[:id])
        rescue
            bad_request
        end

        return {
            :id => params[:id],
            :name => params[:name],
            :parent_folder_id => params[:parent_folder_id]
        }
    end
end
