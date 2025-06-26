
module Api
  module V1
    class AccountsController < Api::BaseController

      def index
        Rails.logger.info("Backend index called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        if params[:company_id].present?
          response = AccountService.list(
            params[:company_id],
            name: params[:name],
            account_type: params[:account_type],
            active: params[:active],
            maxresults: params[:maxresults],
            startposition: params[:startposition]
          )
          
          if response.nil?
            api_error('Failed to fetch accounts', :service_unavailable)
          else
            begin
              render json: JSON.parse(response.body), status: response.code.to_i
            rescue JSON::ParserError => e
              Rails.logger.error("Failed to parse response: #{e.message}")
              api_error('Invalid response format', :internal_server_error)
            end
          end
        else
          api_error('Company ID is required', :bad_request)
        end
      end

      def show
        Rails.logger.info("Backend show called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        if params[:id].present? && params[:company_id].present?
          begin
            response = AccountService.get(params[:id], params[:company_id])
            render json: response.body, status: :ok, content_type: 'application/json'
          rescue => e
            Rails.logger.error("Error fetching account: #{e.message}")
            api_error(e.message, :internal_server_error)
          end
        else
          api_error('Missing required parameters', :bad_request)
        end
      end

      def create
        Rails.logger.info("Backend Create called")
        unless params[:file].present?
          return api_error('No CSV file provided', :bad_request)
        end

        required_headers = ['Account Number', 'Account Name', 'Type', 'Detail Type', 'Parent Account Name']
        valid, error_message = AccountService.valid_csv_file?(params[:file], required_headers)
        Rails.logger.info("CSV validation result: #{valid ? 'Valid' : 'Invalid'}, Error: #{error_message}")
        unless valid
          return api_error("Invalid CSV: #{error_message}", :bad_request)
        end

        unless params[:company_id].present?
          return api_error('Company ID is required', :bad_request)
        end

        results = AccountService.process_account_csv(params[:file], params[:company_id], request.headers)
        
        render json: { 
          message: 'Processing completed',
          successful_rows: results[:successful_rows],
          failed_rows: results[:failed_rows]
        }, status: :ok
      end      
    end
  end
end
