# lib/tasks/heroku.rake

namespace :data do
  desc "Fix CountyClerk records"
  task :fix_county_clerk => :environment do
    # http://www.countyofdane.com/clerk/
    county_clerk = CountyClerk.find_by_county('Dane')
    if county_clerk
      puts "Found CountyClerk record for #{county_clerk.county}"
      if county_clerk.phone_number != '(608) 266-4121'
        puts "Fixing phone number..."
        county_clerk.update_attribute(:phone_number, '(608) 266-4121')
      end
      if county_clerk.email_address != 'county.clerk@co.dane.wi.us'
        puts "Fixing email address..."
        county_clerk.update_attribute(:email_address, 'county.clerk@co.dane.wi.us')
      end
    end
  end
end
