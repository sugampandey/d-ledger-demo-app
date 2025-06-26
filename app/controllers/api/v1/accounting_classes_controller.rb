require 'json'

module Api
  module V1
    class AccountingClassesController < Api::BaseController
      def index
        Rails.logger.info("Backend index called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        response = AccountingClassService.list(
          params[:company_id],
          active: params[:active],
          maxresults: params[:maxresults],
          startposition: params[:startposition]
        )
        
        if response.nil?
          api_error('Failed to fetch accounting classes', :service_unavailable)
        else
          begin
            render json: JSON.parse(response.body), status: response.code.to_i
          rescue JSON::ParserError => e
            Rails.logger.error("Failed to parse response: #{e.message}")
            api_error('Invalid response format', :internal_server_error)
          end
        end
      end
      
      def show
        Rails.logger.info("Backend show called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        if params[:id].present? && params[:company_id].present?
          begin
            response = AccountingClassService.get(params[:id], params[:company_id])
            render json: response.body, status: :ok, content_type: 'application/json'
          rescue => e
            Rails.logger.error("Error fetching accounting class: #{e.message}")
            api_error(e.message, :internal_server_error)
          end
        else
          api_error('Missing required parameters', :bad_request)
        end
      end
      
      def create
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        begin
          permitted_params = accounting_class_params
          response = AccountingClassService.create(permitted_params, request.headers)
          
          if response.nil?
            api_error('Failed to create accounting class', :service_unavailable)
          else
            begin
              response_data = JSON.parse(response.body)
              status_code = response.code.to_i
              if status_code >= 200 && status_code < 300
                accounting_class = AccountingClassService.save_accounting_class(permitted_params, response_data)
                if accounting_class.persisted?
                  render json: response_data, status: response.code.to_i
                else
                  api_error(accounting_class.errors.full_messages.join(', '), :unprocessable_entity)
                end
              else
                # For non-successful responses, just return the response as is
                render json: response_data, status: status_code
              end
            rescue JSON::ParserError => e
              Rails.logger.error("Failed to parse response: #{e.message}")
              api_error('Invalid response format', :internal_server_error)
            end
          end
        rescue StandardError => e
          Rails.logger.error("Error creating accounting class: #{e.message}")
          api_error(e.message, :internal_server_error)
        end
      end

      private 
      def accounting_class_params
        params.permit(
          :name,
          :company_id
        )
      end
    end
  end
end
