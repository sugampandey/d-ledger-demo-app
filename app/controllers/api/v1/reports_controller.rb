require 'json'

module Api
  module V1
    class ReportsController < Api::BaseController
      def balance_sheet
        Rails.logger.info("Balance Sheet report called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        response = ReportService.balance_sheet(
          params[:company_id],
          start_date: params[:start_date],
          end_date: params[:end_date],
          partner_id: params[:partner_id],
          account_id: params[:account_id],
          analytic_class_id: params[:analytic_class_id]
        )
        
        if response.nil?
          api_error('Failed to fetch balance sheet', :service_unavailable)
        else
          begin
            render json: JSON.parse(response.body), status: response.code.to_i
          rescue JSON::ParserError => e
            Rails.logger.error("Failed to parse response: #{e.message}")
            api_error('Invalid response format', :internal_server_error)
          end
        end
      end
      
      def general_ledger
        Rails.logger.info("General Ledger report called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        response = ReportService.general_ledger(
          params[:company_id],
          start_date: params[:start_date],
          end_date: params[:end_date],
          partner_id: params[:partner_id],
          account_id: params[:account_id],
          analytic_class_id: params[:analytic_class_id],
          columns: params[:columns],
          sort_by: params[:sort_by],
          sort_order: params[:sort_order]
        )
        
        if response.nil?
          api_error('Failed to fetch general ledger', :service_unavailable)
        else
          begin
            render json: JSON.parse(response.body), status: response.code.to_i
          rescue JSON::ParserError => e
            Rails.logger.error("Failed to parse response: #{e.message}")
            api_error('Invalid response format', :internal_server_error)
          end
        end
      end

      def profit_loss
        Rails.logger.info("Profit Loss report called")
        Rails.logger.info("Received request with params: #{params.inspect}")

        response = ReportService.profit_loss(
          params[:company_id],
          start_date: params[:start_date],
          end_date: params[:end_date]
        )

        if response.nil?
          api_error('Failed to fetch profit loss', :service_unavailable)
        else
          begin
            render json: JSON.parse(response.body), status: response.code.to_i
          rescue JSON::ParserError => e
            Rails.logger.error("Failed to parse response: #{e.message}")
            api_error('Invalid response format', :internal_server_error)
          end
        end
      end
      
      def balance_sheet_excel
        Rails.logger.info("Balance Sheet Excel download called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        response = ReportService.balance_sheet(
          params[:company_id],
          start_date: params[:start_date],
          end_date: params[:end_date],
          partner_id: params[:partner_id],
          account_id: params[:account_id],
          analytic_class_id: params[:analytic_class_id]
        )
        
        if response.nil?
          api_error('Failed to fetch balance sheet', :service_unavailable)
        else
          begin
            json_data = JSON.parse(response.body)
            file_path = ReportService.json_to_excel(json_data)
            send_file file_path, filename: "balance_sheet_#{Date.today}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          rescue => e
            Rails.logger.error("Failed to generate Excel: #{e.message}")
            api_error('Failed to generate Excel file', :internal_server_error)
          end
        end
      end
      
      def general_ledger_excel
        Rails.logger.info("General Ledger Excel download called")
        Rails.logger.info("Received request with params: #{params.inspect}")
        
        response = ReportService.general_ledger(
          params[:company_id],
          start_date: params[:start_date],
          end_date: params[:end_date],
          partner_id: params[:partner_id],
          account_id: params[:account_id],
          analytic_class_id: params[:analytic_class_id],
          columns: params[:columns],
          sort_by: params[:sort_by],
          sort_order: params[:sort_order]
        )
        
        if response.nil?
          api_error('Failed to fetch general ledger', :service_unavailable)
        else
          begin
            json_data = JSON.parse(response.body)
            file_path = ReportService.json_to_excel(json_data)
            send_file file_path, filename: "general_ledger_#{Date.today}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          rescue => e
            Rails.logger.error("Failed to generate Excel: #{e.message}")
            api_error('Failed to generate Excel file', :internal_server_error)
          end
        end
      end  
      
      
      def profit_loss_excel
        Rails.logger.info("Profit Loss Excel download called")
        Rails.logger.info("Received request with params: #{params.inspect}")

        response = ReportService.profit_loss(
          params[:company_id],
          start_date: params[:start_date],
          end_date: params[:end_date]
        )

        if response.nil?
          api_error('Failed to fetch profit loss', :service_unavailable)
        else
          begin
            json_data = JSON.parse(response.body)
            file_path = ReportService.json_to_excel(json_data)
            send_file file_path, filename: "profit_loss_#{Date.today}.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          rescue => e
            Rails.logger.error("Failed to generate Excel: #{e.message}")
            api_error('Failed to generate Excel file', :internal_server_error)
          end
        end
      end
    end
  end
end
