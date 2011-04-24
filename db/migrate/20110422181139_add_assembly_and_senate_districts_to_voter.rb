class AddAssemblyAndSenateDistrictsToVoter < ActiveRecord::Migration
  def self.up
    add_column :voters, :assembly_district, :integer
    add_column :voters, :senate_district, :integer
  end

  def self.down
    remove_column :voters, :assembly_district
    remove_column :voters, :senate_district
  end
end
