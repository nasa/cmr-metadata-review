require File.expand_path('../../config/environment', __FILE__)
collection = Collection.find_by concept_id: "C1269-SEDAC"
data = collection.records.first.record_datas
# data.each do |d|
#   d.color = "green"
#   puts "d=#{d.color} #{d.column_name} #{d.daac} #{d.feedback} #{d.flag} #{d.last_updated} #{d.opinion} #{d.order_count} #{d.recommendation} #{d.record_id}"
#   d.save!
# end
record = collection.records.first
record.state = Record::STATE_IN_DAAC_REVIEW
record.save!

# puts "collection=#{records.count}"


