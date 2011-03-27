class Jurisdiction < ActiveRecord::Base
  validates_uniqueness_of :district_id, :scope => :type
end
