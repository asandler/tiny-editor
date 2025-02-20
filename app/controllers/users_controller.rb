class UsersController < ApplicationController
    before_action :set_user, only: [:edit, :save, :destroy]
    before_action :require_admin, only: [:index, :destroy]
    before_action :require_registration_open, only: [:new, :create]
    before_action :check_user_access, only: [:edit, :save, :destroy]

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

            u.update_attribute("root_folder_id", f.id) || internal_error

            redirect_to root_path
        else
            flash[:alert] = u.errors.full_messages.join("; ")
            redirect_to "/users/new"
        end
    end

    def edit
    end

    def save
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
        redirect_to root_path if not @user
    end

    def require_admin
        forbidden if not current_user or not current_user.admin?
    end

    def require_registration_open
        redirect_to root_path if not Rails.application.config.registration_open
    end

    def check_user_access
        forbidden if current_user.id != @user.id and not current_user.admin?
    end

    def user_params
        fp = params.permit(:id, :email, :password, :private)
        fp[:private] = fp[:private] == "on" ? true : false
        return fp
    end
end
