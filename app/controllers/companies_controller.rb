class CompaniesController < ApplicationController

  def index
    Rails.logger.info("Frontend CompaniesController Index called")
  end

  def show
    Rails.logger.info("Frontend CompaniesController Show called")
  end

  def create
    Rails.logger.info("Frontend CompaniesController Create called")
  end
end
