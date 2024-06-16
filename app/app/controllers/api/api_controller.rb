module Api
  class ApiController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_resp

    private

    def not_found_resp
      render json: { errors: 'Not Found' }, status: :not_found
    end
  end
end
