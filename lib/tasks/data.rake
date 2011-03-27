# lib/tasks/heroku.rake

namespace :data do
  desc "Fix CountyClerk records"
  task :fix_county_clerk => :environment do
    # http://www.countyofdane.com/clerk/
    county_clerk = CountyClerk.find_by_county_and_phone_number('Dane')
    if county_clerk
      if county_clerk.phone_number == '(608) 266-2611'
        county_clerk.update_attribute(:phone_number, '(608) 266-4601')
      end
      if county_clerk.email == 'OHLSEN@CO.DANE.WI.US'
        county_clerk.update_attribute(:email, 'county.clerk@co.dane.wi.us')
      end
    end
  end
end
