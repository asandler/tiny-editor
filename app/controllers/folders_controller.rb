class FoldersController < ApplicationController
    before_action :require_login
    skip_before_action :require_login, only: [:get, :home], :raise => false

    def get
        get_folder_contents(folder_params[:id])
        @all_folders = []
        @all_folders = Folder.where(user_id: current_user.id) if current_user
    end

    def edit
        @folder = find_user_folder(folder_params[:id])
        @all_folders = []
        @all_folders = Folder.where(user_id: current_user.id) if current_user
    end

    def new
        @parent_folder_id = folder_params[:parent_folder_id]
    end

    def save
        fp = folder_params
        if fp[:id]
            update_folder(find_user_folder(fp[:id]), fp)
        else
            update_folder(new_folder(fp), fp)
        end
    end

    def destroy
        Folder.destroy(folder_params[:id])
        redirect_to root_path
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

    def new_folder pars
        return Folder.new(
            parent_folder_id: pars[:parent_folder_id].to_i,
            user_id: current_user.id,
        )
    end

    def update_folder folder, pars
        folder.name = pars[:name]
        if folder.parent_folder_id
            folder.parent_folder_id = pars[:parent_folder_id]
        end
        if folder.save
            redirect_to "/folders/#{folder.id}"
        else
            internal_error
        end
    end

    def folder_params
        begin
            Integer(params[:id]) if params[:id]
            Integer(params[:parent_folder_id]) if params[:parent_folder_id]
            if params[:name]
                bad_request if params[:name].length == 0
                bad_request if params[:name].length > Rails.application.config.max_folder_name_length
            end
        rescue
            bad_request
        end

        return params.permit(:id, :name, :parent_folder_id)
    end
end
