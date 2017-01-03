# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'


puts 'config'
CSV.foreach("#{Rails.root}/db/seed_data/config.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = Configuration.find_by_id(row_h[:id]) || Configuration.create(row.to_hash)
	recipe.update(row_h)
end

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

puts 'models version'
CSV.foreach("#{Rails.root}/db/seed_data/models_version.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = ModelVersion.find_by_id(row_h[:id]) || ModelVersion.create(row.to_hash)
	recipe.update(row_h)
end


puts 'backtest history'
CSV.foreach("#{Rails.root}/db/seed_data/backtestsHistory.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = BacktestHistoryModel.find_by_id(row_h[:id]) || BacktestHistoryModel.create(row.to_hash)
	recipe.update(row_h)
end


puts 'report'
CSV.foreach("#{Rails.root}/db/seed_data/report_month.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = ReportMonth.find_by_id(row_h[:id]) || ReportMonth.create(row.to_hash)
	recipe.update(row_h)
end

puts 'report details'
CSV.foreach("#{Rails.root}/db/seed_data/report_details_month.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
	row_h = row.to_hash
	recipe = ReportDetailsMonth.find_by_report_month_id_and_model_object_id(row_h[:report_month_id],row_h[:model_object_id]) || ReportDetailsMonth.create(row.to_hash)
	recipe.update(row_h)
end

#puts 'version'
#CSV.foreach("#{Rails.root}/db/seed_data/version.csv", {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all}) do |row|
#	row_h = row.to_hash
#	recipe = ModelVersion.find_by_id(row_h[:id]) || ModelVersion.create(row.to_hash)
#	recipe.update(row_h)
#end
