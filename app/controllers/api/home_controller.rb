module Api
  class HomeController < ApplicationController
    def index
      render 'api/home/index'
    end
  end
end
