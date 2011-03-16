# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Gotv::Application.initialize!

File.join(File.dirname(__FILE__), "credentials").tap do |fn|
  require fn if File.exists?("#{fn}.rb")
end
