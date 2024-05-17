class ApplicationController < ActionController::Base
    def home
        if current_user
            redirect_to controller: "folders", action: "get", id: current_user.root_folder_id
        elsif params[:user_id]
            u = User.find(params[:user_id]) || not_found
            redirect_to controller: "folders", action: "get", id: u.root_folder_id
        else
            redirect_to login_path
        end
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

    def internal_error
        raise "Internal error"
    end

    def bad_request
        raise ActionController::BadRequest.new("Bad Request")
    end

    def forbidden
        raise "Forbidden"
    end
end
