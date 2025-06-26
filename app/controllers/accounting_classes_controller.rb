class AccountingClassesController < ApplicationController
  def index
    Rails.logger.info("Frontend AccountingClassesController Index called")
  end

  def show
    Rails.logger.info("Frontend AccountingClassesController Show called")
  end

  def create
    Rails.logger.info("Frontend AccountingClassesController Create called")
  end
end
