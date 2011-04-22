class Jurisdiction < ActiveRecord::Base
  has_many :elections
  validates_uniqueness_of :district_id, :scope => :type
end
