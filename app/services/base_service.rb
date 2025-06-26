require 'net/http'
require 'json'
require 'csv'

class BaseService

  def self.valid_csv_file?(file, required_headers = nil)
    return [false, "File doesn't have required methods"] unless file.respond_to?(:content_type)
    
    content_type = file.content_type.to_s.downcase
    valid_types = ['text/csv', 'application/csv', 'application/x-csv']
    
    return [false, "Invalid content type: #{content_type}"] unless valid_types.include?(content_type)
    
    begin
      csv_text = file.read.force_encoding('UTF-8')
      csv_text.gsub!("\xEF\xBB\xBF", '') # Remove UTF-8 BOM
      csv_data = CSV.parse(csv_text, headers: true)
      file.rewind # Reset file pointer for later processing

      Rails.logger.info("CSV Headers: #{csv_data.headers.inspect}")
      Rails.logger.info("Passed Headers: #{required_headers}")
      
      # Validate headers if required_headers is provided
      if required_headers.is_a?(Array) && !required_headers.empty?
        csv_headers = csv_data.headers || []
        Rails.logger.info("CSV Headers: #{csv_headers.inspect}")
        
        # Check if all required headers are present
        missing_headers = required_headers - csv_headers
        Rails.logger.info("Missing Headers: #{missing_headers.inspect}")
        if missing_headers.any?
          return [false, "Missing required headers: #{missing_headers.join(', ')}"]
        end
        
        # Check if there are any extra headers
        extra_headers = csv_headers - required_headers
        if extra_headers.any?
          return [false, "Unexpected headers found: #{extra_headers.join(', ')}"]
        end
      end
      
      [true, nil]
    rescue CSV::MalformedCSVError => e
      [false, "Malformed CSV: #{e.message}"]
    rescue StandardError => e
      [false, "Error processing CSV: #{e.message}"]
    end
  end 

  def self.process_csv_file(file, company_id, headers, service_class, build_payload_method, save_record_method)
    csv_text = file.read
    csv_text = csv_text.force_encoding('UTF-8')
    csv_text.gsub!("\xEF\xBB\xBF", '') if csv_text.start_with?("\xEF\xBB\xBF")
    csv = CSV.parse(csv_text, headers: true)
    successful_rows = []
    failed_rows = []
  
    ActiveRecord::Base.transaction do
      # Process in batches of 100
      csv.each_slice(100).with_index do |batch, batch_index|
        batch_results = batch.map.with_index do |row, index|
          actual_index = (batch_index * 100) + index + 1

          if row.fields.compact.empty? || row.fields.all? { |field| field.nil? || field.to_s.strip.empty? }
            next { success: true, row: actual_index, data: { skipped: true, reason: 'All values blank' } }
          else
            begin
              payload = send(build_payload_method, row)
              response = service_class.create(payload, company_id, headers)
              
              if response&.is_a?(Net::HTTPSuccess)
                response_data = JSON.parse(response.body)
                record = send(save_record_method, row, response_data)
                
                if record.persisted?
                  { success: true, row: actual_index, data: JSON.parse(response.body) }
                else
                  { success: false, row: actual_index, error: record.errors.full_messages.join(', ') }
                end
              else
                { success: false, row: actual_index, error: response&.body || 'No response received' }
              end
            rescue StandardError => e
              { success: false, row: actual_index, error: e.message }
            end
          end
        end
  
        successful_rows.concat(batch_results.select { |r| r[:success] })
        failed_rows.concat(batch_results.reject { |r| r[:success] })
      end
    end
  
    {
      success: failed_rows.empty?,
      successful_rows: successful_rows,
      failed_rows: failed_rows
    }
  end
end
  