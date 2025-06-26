require 'net/http'
require 'uri'
require 'json'
require 'csv'

class VendorService < BaseService
  def self.create(payload, company_id, headers = {})
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}vendors")
    uri = URI("#{ENV['ODOO_URL']}vendors")
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

  def self.get(vendor_id, company_id)
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}vendors/#{vendor_id}?company_id=#{company_id}")
    uri = URI("#{ENV['ODOO_URL']}vendors/#{vendor_id}?company_id=#{company_id}")
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
    
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}vendors?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}vendors?#{query_string}")
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

  def self.process_vendor_csv(file, company_id, headers)
    process_csv_file(file, company_id, headers, self, :build_payload, :save_vendor)
  end


  def self.save_vendor(row, response_data)
    return unless response_data['Vendor']
    vendor = Vendor.new(
      name: response_data['Vendor']['DisplayName'],
      odoo_id: response_data['Vendor']['Id'],
    )
    if vendor.save
      vendor
    else
      Rails.logger.error("Vendor validation failed: #{vendor.errors.full_messages}")
      vendor
    end
  rescue StandardError => e
    Rails.logger.error("Error saving vendor: #{e.message}")
    Vendor.new.tap { |v| v.errors.add(:base, e.message) }
  end

  def self.build_payload(row)
    Rails.logger.info("Building payload for vendor: #{row}")
    {
      "DisplayName" => row['DisplayName']&.strip || '',
      "CompanyName" => row['CompanyName']&.strip || '',
      "PrimaryEmailAddr" => {'Address' => row['Email']&.strip || ''},
      "PrimaryPhone" => {'FreeFormNumber' => row['Phone']&.strip || ''},
      "Title" => row['Title']&.strip || '',
      "Mobile" => {'FreeFormNumber' => row['Mobile']&.strip || ''},
    }
  end
end
