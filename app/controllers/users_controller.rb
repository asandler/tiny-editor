class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :save, :destroy]
    before_action :require_login
    skip_before_action :require_login, only: [:new, :create], :raise => false

    def index
        @users = User.all
    end

    def new
        @user = User.new
    end

    def create
        u = User.new(user_params)
        if u.save
            f = Folder.new(user_id: u.id, name: "Root folder")
            f.save || internal_error

            p u
            u.update_attribute("root_folder_id", f.id) || internal_error

            redirect_to root_path
        else
            render :new
        end
    end

    def edit
    end

    def save
        forbidden if current_user.id != @user.id
        if @user.update(user_params)
            redirect_to root_path
        else
            render :edit
        end
    end

    def destroy
        @user.destroy
        redirect_to users_url
    end

private
    def set_user
        @user = User.find(params[:id])
    end

    def user_params
        fp = params.permit(:id, :email, :password, :private)
        fp[:private] = fp[:private] == "on" ? true : false
        return fp
    end
end
