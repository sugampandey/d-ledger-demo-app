require 'net/http'
require 'uri'
require 'json'
require 'csv'

class CustomerService < BaseService
  def self.create(payload, company_id, headers = {})
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}customers")
    uri = URI("#{ENV['ODOO_URL']}customers")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {
      'Content-Type' => 'application/json',
      'X-Company-Id' => company_id,
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
    })

    request.body = payload.to_json

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    nil
  end

  def self.get(customer_id, company_id)
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}customers/#{customer_id}?company_id=#{company_id}")
    uri = URI("#{ENV['ODOO_URL']}customers/#{customer_id}?company_id=#{company_id}")
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

  def self.list(company_id, name: nil, email: nil, active: nil, maxresults: nil, startposition: nil)
    query_params = {
      company_id: company_id,
    }
    
    # Add optional parameters if they're present
    query_params[:DisplayName] = name if name
    query_params[:active] = active if active
    query_params[:maxresults] = maxresults if maxresults
    query_params[:startposition] = startposition if startposition
  
    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)
    
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}customers?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}customers?#{query_string}")
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

  def self.process_customer_csv(file, company_id, headers)
    process_csv_file(file, company_id, headers, self, :build_payload, :save_customer)
  end

  def self.save_customer(row, response_data)
    return unless response_data['Customer']
    customer = Customer.new(
      name: response_data['Customer']['DisplayName'],
      odoo_id: response_data['Customer']['Id'],
    )
    if customer.save
      customer
    else
      Rails.logger.error("Customer validation failed: #{customer.errors.full_messages}")
      customer
    end
  rescue StandardError => e
    Rails.logger.error("Error saving customer: #{e.message}")
    Customer.new.tap { |c| c.errors.add(:base, e.message) }
  end

  def self.build_payload(row)
    Rails.logger.info("Building payload for customer: #{row}")
    {
      "DisplayName" => row['DisplayName']&.strip || '',
      "CompanyName" => row['CompanyName']&.strip || '',
      "PrimaryEmailAddr" => {'Address' => row['Email']&.strip || ''},
      "PrimaryPhone" => {'FreeFormNumber' => row['Phone']&.strip || ''},
      "Title" => row['Title']&.strip || ''
    }
  end
end
