# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

puts 'risks'
CSV.foreach("#{Rails.root}/db/seed_data/risks.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = RiskModel.find_by_id(row_h[:id]) || RiskModel.create(row.to_hash)
	recipe.update(row_h)
end

puts 'areas'
CSV.foreach("#{Rails.root}/db/seed_data/areas.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = AreaModel.find_by_id(row_h[:id]) || AreaModel.create(row.to_hash)
	recipe.update(row_h)
end

puts 'models'
CSV.foreach("#{Rails.root}/db/seed_data/models.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = ModelObject.find_by_id(row_h[:id]) || ModelObject.create(row.to_hash)
	recipe.update(row_h)
end