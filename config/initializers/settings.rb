# support yaml and heroku config vars, preferring ENV for heroku
HEROKU_CONFIG = YAML.load_file("#{Rails.root}/config/heroku.yml")[Rails.env] rescue {}
HEROKU_CONFIG ||= {}
SETTINGS_CONFIG = YAML.load_file("#{Rails.root}/config/settings.yml")[Rails.env]
APP_CONFIG = HEROKU_CONFIG.merge(SETTINGS_CONFIG).merge(ENV).symbolize_keys
