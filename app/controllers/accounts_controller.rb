class AccountsController < ApplicationController
  def index
    Rails.logger.info("Frontend AccountsController Index called")
  end

  def show
    Rails.logger.info("Frontend AccountsController Show called")
  end

  def create
    Rails.logger.info("Frontend AccountsController Create called")
  end
end
