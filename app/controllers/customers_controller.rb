class CustomersController < ApplicationController
  def index
    Rails.logger.info("Frontend CustomersController Index called")
  end

  def show
    Rails.logger.info("Frontend CustomersController Show called")
  end

  def create
    Rails.logger.info("Frontend CustomersController Create called")
  end
end
