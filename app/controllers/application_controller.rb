class ApplicationController < ActionController::Base
  include Facebooker2::Rails::Controller
  protect_from_forgery
end
