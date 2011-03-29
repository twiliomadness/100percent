# lib/tasks/heroku.rake

namespace :data do
  desc "Fix CountyClerk records"
  task :fix_county_clerk => :environment do
    counties = YAML.load_file("#{Rails.root}/config/county_clerks.yml")
    counties.each do |county_name, county_data|
      puts "Saving #{county_name}"
      county_clerk = CountyClerk.find_or_create_by_county(county_name)
      county_clerk.update_attributes(county_data)
    end
  end
end
