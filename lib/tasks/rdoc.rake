task :rdoc => :environment do
  Dir.chdir('app/models') do
    p %x{rdoc}
  end
  %x{rm -rf public/doc}
  #moving the newly created doc folder to public for static serving
  %x{mv app/models/doc/ public/}

  #replacing default css with custom one stored in the public folder
  %x{rm public/doc/css/rdoc.css}
  %x{cp public/rdoc_files/rdoc.css public/doc/css/}
  %x{cp public/rdoc_files/darkfish.js public/doc/js/}
  %x{cp public/rdoc_files/fonts.css public/doc/css/}

end