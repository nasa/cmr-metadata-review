task :rdoc => :environment do
  Dir.chdir('app/models') do
    p %x{rdoc}
  end
  %x{mv app/models/doc/ public/}
end