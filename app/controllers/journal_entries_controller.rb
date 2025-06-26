class JournalEntriesController < ApplicationController
  def index
    Rails.logger.info("Frontend JournalEntriesController Index called")
  end

  def show
    Rails.logger.info("Frontend JournalEntriesController Show called")
  end

  def create
    Rails.logger.info("Frontend JournalEntriesController Create called")
  end
end
