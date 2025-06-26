# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session
    
    # Common API configurations
    # before_action :authenticate_api_request
        
    # def authenticate_api_request
    #   # Add your API authentication logic here
    #   # For example, token-based authentication
    # end

    def api_error(message, status = :unprocessable_entity)
      render json: { error: message }, status: status
    end
  end
end
