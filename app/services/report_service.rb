require 'net/http'
require 'uri'
require 'json'

class ReportService
  def self.balance_sheet(company_id, start_date: nil, end_date: nil, partner_id: nil, account_id: nil, analytic_class_id: nil)
    query_params = { company_id: company_id }
    query_params[:start_date] = start_date if start_date
    query_params[:end_date] = end_date if end_date
    query_params[:partner_id] = partner_id if partner_id
    query_params[:account_id] = account_id if account_id
    query_params[:analytic_class_id] = analytic_class_id if analytic_class_id

    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)

    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}account_balance?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}account_balance?#{query_string}")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending balance sheet request: #{e.message}")
    nil
  end

  def self.general_ledger(company_id, start_date: nil, end_date: nil, partner_id: nil, account_id: nil, 
                          analytic_class_id: nil, columns: nil, sort_by: nil, sort_order: nil)
    query_params = { company_id: company_id }
    query_params[:start_date] = start_date if start_date
    query_params[:end_date] = end_date if end_date
    query_params[:partner_id] = partner_id if partner_id
    query_params[:account_id] = account_id if account_id
    query_params[:analytic_class_id] = analytic_class_id if analytic_class_id
    query_params[:columns] = columns if columns
    query_params[:sort_by] = sort_by if sort_by
    query_params[:sort_order] = sort_order if sort_order

    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)

    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}general_ledger?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}general_ledger?#{query_string}")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending general ledger request: #{e.message}")
    nil
  end

  def self.profit_loss(company_id, start_date: nil, end_date: nil)
    query_params = { company_id: company_id }
    query_params[:start_date] = start_date if start_date
    query_params[:end_date] = end_date if end_date

    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)

    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}profit_loss?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}profit_loss?#{query_string}")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending profit loss request: #{e.message}")
    nil
  end

  def self.json_to_excel(json_data)
    require 'axlsx'
    
    # Create a temporary file path
    temp_file = Rails.root.join('tmp', "report_#{Time.now.to_i}.xlsx")
    
    # Create a new Excel workbook
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: json_data["Header"]["ReportName"] || "Report") do |sheet|
        # Add header row with column titles
        header_row = []
        json_data["Columns"]["Column"].each do |col|
          header_row << (col["ColTitle"].empty? ? col["ColType"] : col["ColTitle"])
        end
        sheet.add_row header_row, style: p.workbook.styles.add_style(b: true)
        
        # Process rows recursively
        process_rows(sheet, json_data["Rows"]["Row"])
      end
      
      # Save the Excel file
      p.serialize(temp_file)
    end
    
    return temp_file
  end
  
  private
  
  def self.process_rows(sheet, rows, indent_level = 0)
    return if rows.nil? || rows.empty?
    
    rows = [rows] unless rows.is_a?(Array)
    
    rows.each do |row|
      if row["type"] == "Section" || row["type"].nil?
        # Add section header if present
        if row["Header"]
          col_data = row["Header"]["ColData"]
          values = col_data.map { |col| col["value"] }
          values[0] = "  " * indent_level + values[0] if values[0]
          sheet.add_row values, style: sheet.workbook.styles.add_style(b: true)
        end
        
        # Process nested rows
        if row["Rows"] && row["Rows"]["Row"]
          process_rows(sheet, row["Rows"]["Row"], indent_level + 1)
        end
        
        # Add section summary if present
        if row["Summary"]
          col_data = row["Summary"]["ColData"]
          values = col_data.map { |col| col["value"] }
          values[0] = "  " * indent_level + values[0] if values[0]
          sheet.add_row values, style: sheet.workbook.styles.add_style(b: true)
        end
      elsif row["type"] == "Data"
        # Add data row
        col_data = row["ColData"]
        values = col_data.map { |col| col["value"] }
        values[0] = "  " * indent_level + values[0] if values[0]
        sheet.add_row values
      end
    end
  end  
end
