require 'json'

module Api
  module V1
    class JournalEntriesController < Api::BaseController
      def index
        Rails.logger.info("Backend index called for journal entries")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        response = JournalEntryService.list(
          company_id: params[:company_id],
          journal_id: params[:journal_id],
          date_from: params[:date_from],
          date_to: params[:date_to],
          max_results: params[:max_results],
          start_position: params[:start_position]
        )
        
        if response.nil?
          api_error('Failed to fetch journal entries', :service_unavailable)
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
        Rails.logger.info("Backend show called for journal entry")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        if params[:id].present? && params[:company_id].present?
          begin
            response = JournalEntryService.get(params[:id], params[:company_id])
            render json: response.body, status: :ok, content_type: 'application/json'
          rescue => e
            Rails.logger.error("Error fetching journal entry: #{e.message}")
            api_error(e.message, :internal_server_error)
          end
        else
          api_error('Missing required parameters', :bad_request)
        end
      end
      
      def create
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        begin
          permitted_params = journal_entry_params
          response = JournalEntryService.create(permitted_params, request.headers)
          
          if response.nil?
            api_error('Failed to create journal entry', :service_unavailable)
          else
            begin
              response_data = JSON.parse(response.body)
              status_code = response.code.to_i
              if status_code >= 200 && status_code < 300
                journal_entry = JournalEntryService.save_journal_entry(permitted_params, response_data)
                if journal_entry.persisted?
                  render json: response_data, status: response.code.to_i
                else
                  api_error(journal_entry.errors.full_messages.join(', '), :unprocessable_entity)
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
          Rails.logger.error("Error creating journal entry: #{e.message}")
          api_error(e.message, :internal_server_error)
        end
      end

      private 
      def journal_entry_params
        params.permit(
          :company_id,
          :description,
          :txn_date,
          journal_lines: [
            :amount,
            :description,
            :posting_type,
            :account_id,
            :partner_id,
            :class_id
          ]
        )
      end
    end
  end
end
