# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
  user = User.new
user.email = 'abaker@element84.com'
user.password = 'Password101'
user.admin = true
user.curator = true
user.save

  user = User.new
user.email = 'andrew@element84.com'
user.password = 'Password101'
user.admin = true
user.curator = true
user.save

  user = User.new
user.email = 'general@element84.com'
user.password = 'Password101'
user.admin = false
user.curator = false
user.save

# collection = Collection.new
# collection.concept_id = "C167310-GHRC"
# collection.short_name = "gailong"
# collection.save

# record = Record.new
# record.recordable = collection
# record.revision_id = 33
# record.closed = false
# record.rawJSON = '{"ShortName":"gailong","VersionId":"1","InsertTime":"1996-07-12T00:00:00Z","LastUpdate":"2012-01-07T14:34:47Z","LongName":"GAI LONG RANGE LIGHTNING NETWORK","DataSetId":"GAI LONG RANGE LIGHTNING NETWORK V1","Description":"The US National Lightning Detection Network is a commercial network that records the time, polarity, signal strength, and number of cloud-to-ground lightning flashes over the western half of the northern hemisphere with the CONUS masked out."}'

# record.save

# ingest = Ingest.new
# ingest.user = user
# ingest.record = record
# ingest.date_ingested = DateTime.now
# ingest.save

# comment = Comment.new
# comment.record = record
# comment.user_id = -1
# comment.total_comment_count = 0
# comment.rawJSON = '{"ShortName":"","VersionId":"","InsertTime":"","LastUpdate":"","LongName":"","DataSetId":"","Description":""}'

# comment.save


# record_row = RecordRow.new
# record_row.record_id = record.id;
# record_row.row_name = "recommendation"
# record_row.rawJSON = '{"ShortName":"ok","VersionId":"ok","InsertTime":"ok","LastUpdate":"ok","LongName":"ok","DataSetId":"ok","Description":"ok"}'
# record_row.save

# record_row = RecordRow.new
# record_row.record_id = record.id;
# record_row.row_name = "flag"
# record_row.rawJSON = '{"ShortName":[],"VersionId":[],"InsertTime":[],"LastUpdate":[],"LongName":[],"DataSetId":[],"Description":[]}'
# record_row.save

# record_row = RecordRow.new
# record_row.record_id = record.id;
# record_row.row_name = "second_opinion"
# record_row.rawJSON = '{"ShortName":false,"VersionId":false,"InsertTime":false,"LastUpdate":false,"LongName":false,"DataSetId":false,"Description":false}'
# record_row.save

# flag = Flag.new
# flag.record_id = record.id
# flag.user_id = -1
# flag.total_flag_count = 0
# flag.rawJSON = '{"ShortName":"green","VersionId":"green","InsertTime":"green","LastUpdate":"green","LongName":"green","DataSetId":"green","Description":"green"}'
# flag.save

# review = Review.new
# review.record_id = record.id
# review.user_id = 1
# review.review_completion_date = '2017-02-14 18:11:27.671843'
# review.review_state = 1
# review.comment = 'Review #1 is done'
# review.save

# review = Review.new
# review.record_id = record.id
# review.user_id = 2
# review.review_completion_date = '2017-02-14 18:17:27.671843'
# review.review_state = 1
# review.comment = 'Review #2 is done'
# review.save



