# app/jobs/company_csv_import_job.rb
require 'csv'

class CompanyCsvImportJob < ActiveJob::Base
  queue_as :default

  def perform(file_path)
    CSV.foreach(file_path, headers: true) do |row|
      Api::CompanyProxyService.new.create_company({
        Name: row['Name'],
        PrimaryEmailAddr: { Address: row['PrimaryEmailAddr.Address'] }
      })
    end
  end
end
