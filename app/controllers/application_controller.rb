class ApplicationController < ActionController::Base
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
