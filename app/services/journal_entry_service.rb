# app/services/journal_entry_service.rb
require 'net/http'
require 'uri'
require 'json'

class JournalEntryService
  def self.create(params, headers = {})
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}journal-entries")
    uri = URI("#{ENV['ODOO_URL']}journal-entries")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {
        'Content-Type' => 'application/json',
        'X-Company-Id' => params[:company_id],
        'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
      }
    )

    request.body = build_payload(params)
    response = http.request(request)
    Rails.logger.info("Response: #{response.body}")
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    OpenStruct.new(success?: false, error_message: e.message)
  end

  def self.get(journal_entry_id, company_id)
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}journal-entries/#{journal_entry_id}?company_id=#{company_id}")
    uri = URI("#{ENV['ODOO_URL']}journal-entries/#{journal_entry_id}")
    uri.query = URI.encode_www_form({ company_id: company_id })
    
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    nil
  end

  def self.list(company_id:, journal_id: nil, date_from: nil, date_to: nil, max_results: nil, start_position: nil)
    query_params = { company_id: company_id }
    query_params[:journal_id] = journal_id if journal_id
    query_params[:date_from] = date_from if date_from
    query_params[:date_to] = date_to if date_to
    query_params[:maxresults] = max_results if max_results
    query_params[:startposition] = start_position if start_position

    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)

    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}journal-entries?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}journal-entries?#{query_string}")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    nil
  end

  def self.save_journal_entry(params, response_data)
    return unless response_data['JournalEntry']
    
    journal_entry = JournalEntry.new(
      # description: response_data['JournalEntry']['Description'],
      odoo_id: response_data['JournalEntry']['Id'],
    )

    if journal_entry.save
      journal_entry
    else
      Rails.logger.error("Journal entry validation failed: #{journal_entry.errors.full_messages}")
      journal_entry
    end
  rescue StandardError => e
    Rails.logger.error("Error saving journal entry: #{e.message}")
    JournalEntry.new.tap { |je| je.errors.add(:base, e.message) }
  end

  def self.build_payload(params)
    journal_lines = params[:journal_lines] || []
    
    payload = {
      "Description" => params[:description],
      "TxnDate" => params[:txn_date],
      "Line" => journal_lines.map do |line|
        {
          "JournalEntryLineDetail" => {
            "PostingType" => line[:posting_type],
            "AccountRef" => {
              "name" => nil,
              "value" => line[:account_id]
            },
            "ClassRef" => {
              "name" => nil,
              "value" => line[:class_id]
            },
            "Entity" => {
              "Type" => nil, 
              "EntityRef" => {
                "name" => nil,
                "value" => line[:partner_id]
              }
            }
          },
          "DetailType" => "JournalEntryLineDetail",
          "Amount" => line[:amount].to_f,
          "Description" => line[:description]
        }
      end
    }
    
    payload.to_json
  end  
end
