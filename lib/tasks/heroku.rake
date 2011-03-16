# lib/tasks/heroku.rake

namespace :heroku do
  desc "Read config/heroku.yml and send config vars to heroku"
  task :config, :environment do |t, args|
    environment = args[:environment]
    if !environment
      raise 'No environment specified; use rake heroku:config[environment]'
    end
    puts "Sending config vars for #{environment}"
    CONFIG = YAML.load_file('config/heroku.yml')[environment] rescue {}
    app_name = CONFIG['app_name']
    command = "heroku config:add"
    # TODO: Handle variables with embedded spaces?
    CONFIG.each {|key, val| command << " #{key}=#{val} " if val && key != 'app_name'}
    command << " --app #{app_name}"
    system command
  end
end
