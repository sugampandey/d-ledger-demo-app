require 'net/http'
require 'uri'
require 'json'
require 'csv'

class AccountService < BaseService
  def self.create(payload, company_id, headers = {})
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}accounts")
    uri = URI("#{ENV['ODOO_URL']}accounts")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'X-Company-Id' => company_id,
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN'] # pass headers from controller if needed
    })

    request.body = payload.to_json

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    nil
  end

  def self.get(account_id, company_id)
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}accounts/#{account_id}?company_id=#{company_id}")
    uri = URI("#{ENV['ODOO_URL']}accounts/#{account_id}?company_id=#{company_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    Rails.logger.info("ODOO_ACCESS_TOKEN = #{ENV['ODOO_ACCESS_TOKEN']}")

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      # 'X-Company-Id' => company_id,
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN'] # pass headers from controller if needed
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    nil
  end

  
  def self.list(company_id, name: nil, account_type: nil, active: nil, maxresults: nil, startposition: nil)
    query_params = {
      company_id: company_id,
    }
    
    # Add optional parameters if they're present
    query_params[:name] = name if name
    query_params[:account_type] = account_type if account_type
    query_params[:active] = active if active
    query_params[:maxresults] = maxresults if maxresults
    query_params[:startposition] = startposition if startposition
  
    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)
    
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}accounts?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}accounts?#{query_string}")
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
  
  def self.process_account_csv(file, company_id, headers)
    process_csv_file(file, company_id, headers, self, :build_payload, :save_account)
  end
  

  def self.save_account(row, response_data)
    return unless response_data['Account']
    account = Account.new(
      name: response_data['Account']['Name'],
      odoo_id: response_data['Account']['Id'],
      # docyt_id: 'docyt_id'
    )
    if account.save
      account
    else
      Rails.logger.error("Account validation failed: #{account.errors.full_messages}")
      account
    end
  rescue StandardError => e
    Rails.logger.error("Error saving account: #{e.message}")
    Account.new.tap { |a| a.errors.add(:base, e.message) }
  end

  def self.build_payload(row)
    Rails.logger.info("Building payload for account: #{row}")
    Rails.logger.info("Building payload for Account Name: #{row['Account Name']}")
    Rails.logger.info("Building payload for Classification: #{row['Classification']}")
    Rails.logger.info("Building payload for Type: #{row['Type']}")
    Rails.logger.info("Building payload for Detail Type: #{row['Detail Type']}")
    Rails.logger.info("Building payload for Account Number: #{row['Account Number']}")
    {
      "Name" => row['Account Name']&.strip || '',
      "Classification" => row['Classification']&.strip || '',
      "AccountType" => row['Type']&.strip || '',
      "AccountSubType" => row['Detail Type']&.strip || '',
      "AcctNum" => row['Account Number']&.strip || '',
      "CurrencyRef" => {
        "value" => "USD"
      }
    }
  end
end
