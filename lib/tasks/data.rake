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
  
  desc "Add May 5th Special Elections"
  task :add_elections => :environment do
    elections = YAML.load_file("#{Rails.root}/config/elections.yml")
    elections.each do |election_name, election_data|
      puts "Saving jurisdiction..."
      jurisdiction_data = election_data["jurisdiction"]
      klass = jurisdiction_data["type"].classify.constantize
      jurisdiction = klass.find_or_create_by_district_id(jurisdiction_data["district_id"])
      puts "Saving #{election_name}"
      election = Election.find_or_create_by_name_and_date_and_jurisdiction_id(election_data["name"], Chronic.parse(election_data["date"]), jurisdiction.id)
    end
  end
end
