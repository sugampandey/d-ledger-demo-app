class VendorsController < ApplicationController
  def index
    Rails.logger.info("Frontend VendorsController Index called")
  end

  def show
    Rails.logger.info("Frontend VendorsController Show called")
  end

  def create
    Rails.logger.info("Frontend VendorsController Create called")
  end
end
