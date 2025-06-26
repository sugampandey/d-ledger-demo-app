# app/services/accounting_class_service.rb
require 'net/http'
require 'uri'
require 'json'

class AccountingClassService
  def self.create(params, headers = {})
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}analytic-class")
    uri = URI("#{ENV['ODOO_URL']}analytic-class")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.path, {
        'Content-Type' => 'application/json',
        'X-Company-Id' => params[:company_id],
        'X-Access-Token' => ENV['ODOO_ACCESS_TOKEN']
      }
    )
    request.body = build_payload(params)
    response = http.request(request)
    response
  rescue => e
    Rails.logger.error("Exception while sending request: #{e.message}")
    OpenStruct.new(success?: false, error_message: e.message)
  end

  def self.get(accounting_class_id, company_id)
    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}analytic-class/#{accounting_class_id}?company_id=#{company_id}")
    uri = URI("#{ENV['ODOO_URL']}analytic-class/#{accounting_class_id}")
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

  def self.list(company_id, active: nil, maxresults: nil, startposition: nil)
    query_params = {
      company_id: company_id,
    }
    query_params[:active] = active if active
    query_params[:maxresults] = maxresults if maxresults
    query_params[:startposition] = startposition if startposition

    # Convert query params to URL-encoded string
    query_string = URI.encode_www_form(query_params)

    Rails.logger.info("Sending request to #{ENV['ODOO_URL']}analytic-class?#{query_string}")
    uri = URI("#{ENV['ODOO_URL']}analytic-class?#{query_string}")
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

  def self.save_accounting_class(params, response_data)
    return unless response_data['Class']
    Rails.logger.info("Saving accounting class: #{response_data}")
    
    accounting_class = AccountingClass.new(
      name: response_data['Class']['Name'],
      odoo_id: response_data['Class']['Id'],
    )

    if accounting_class.save
      accounting_class
    else
      Rails.logger.error("AccountingClass validation failed: #{accounting_class.errors.full_messages}")
      accounting_class
    end
  rescue StandardError => e
    Rails.logger.error("Error saving accounting class: #{e.message}")
    AccountingClass.new.tap { |ac| ac.errors.add(:base, e.message) }
  end

  def self.build_payload(params)
    payload = {
        Name: params[:name],
      }
    payload.to_json
  end
end
