require File.expand_path('../../config/environment', __FILE__)

puts ENV['urs_client_id'], Cmr.get_cmr_base_url
acl = AclDao.new("971fd8d4f29361e3a12bcfd096f518bf80cdd11f782057690fded3539f11d59e", ENV['urs_client_id'], Cmr.get_cmr_base_url)
m = acl.get_all_groups('chris.gokey')
m.each do |i|
  puts "first=#{i[0]},second=#{i[1]}"
end

#results = first={"revision_id"=>16, "concept_id"=>"ACL1200303120-CMR", "identity_type"=>"System", "name"=>"System - DASHBOARD_ADMIN", "location"=>"https://cmr.sit.earthdata.nasa.gov:443/access-control/acls/ACL1200303120-CMR"},second={"group_permissions"=>[{"group_id"=>"AG1200301545-CMR", "permissions"=>["create"]}, {"group_id"=>"AG1200211473-CMR", "permissions"=>["create", "read", "update", "delete"]}], "system_identity"=>{"target"=>"DASHBOARD_ADMIN"}}

# r = Record.find_by id: 24
# prior = r.prior_revision_record
# preserved, not_preserved = r.copy_recommendations(prior)
# puts "preserved=#{preserved} not=#{not_preserved}"


# Collection.all.each do |collection|
#   if (collection.granules.count > 1)
#     puts collection.concept_id
#     m = {}
#     collection.granules.each do |granule|
#       granule.records.each do |record|
#         key = "#{granule.concept_id}/#{record.revision_id}"
#         if m[key].nil?
#           m[key] = 1
#         else
#           m[key] = m[key]+1
#         end
#       end
#     end
#     # m.keys.each do |key|
#     #   puts "  #{key} #{m[key]}"
#     # end
#
#   end
# end
# metric_data = MetricData.new(Collection.all)
# puts "count=#{metric_data.updated_count}"
# puts "metric data=#{metric_data}"