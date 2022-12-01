task :validate => :environment do
  metadata= File.read("/tmp/file.xml")
  result = Quarc.instance.validate('echo-c', metadata)
  puts(result)
end
