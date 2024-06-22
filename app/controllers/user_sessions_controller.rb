class UserSessionsController < ApplicationController
    before_action :require_login, only: [:destroy], :raise => false

    def new
        @user = User.new
    end

    def create
        if @user = login(params[:email], params[:password])
            redirect_to root_path
        end
        flash[:alert] = "Login failed"
        redirect_to login_path
    end

    def destroy
        logout
        redirect_to login_path
    end
end
