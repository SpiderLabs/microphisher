class HomeController < ApplicationController
  skip_filter :require_login, only: [ :index ]
end
