# app/services/company_proxy_service.rb
require 'net/http'
require 'uri'
require 'json'

class CompanyService

  def self.create(params, headers = {})
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}companies")
    uri = URI("#{ENV['ODOO_URL']}companies")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path,{
        'Content-Type' => 'application/json',
        'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
      }
    )

    request.body = params.to_json
    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    OpenStruct.new(success?: false, error_message: e.message)
  end

  def self.get(company_id)
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}companies/#{company_id}")
    uri = URI("#{ENV['ODOO_URL']}companies/#{company_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    Rails.logger.info("ODOO_ACCESS_TOKEN = #{ENV['ODOO_ACCESS_TOKEN']}")

    request = Net::HTTP::Get.new(uri.request_uri, {
      'Content-Type' => 'application/json',
      'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN'] # pass headers from controller if needed
    })

    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    nil
  end

  def self.list(active: nil, maxresults: nil, startposition: nil)
    query_params = {}
    query_params[:active] = active if active
    query_params[:maxresults] = maxresults if maxresults
    query_params[:startposition] = startposition if startposition

    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)

    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}companies?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}companies?#{query_string}")
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

  def self.save_company(params, response_data)
    return unless response_data['Company']
    
    company = Company.new(
      name: response_data['Company']['Name'],
      odoo_id: response_data['Company']['Id']
    )

    if company.save
      company
    else
      Rails.logger.error("Company validation failed: #{company.errors.full_messages}")
      company
    end
  rescue StandardError => e
    Rails.logger.error("Error saving company: #{e.message}")
    Company.new.tap { |c| c.errors.add(:base, e.message) }
  end
end

