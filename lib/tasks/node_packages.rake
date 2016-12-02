namespace :node_packages do
  desc 'install packages'
  task install: :environment do
    Dir.chdir("#{Rails.root}/vendor") do
      system('npm', 'install')
    end
  end

  desc 'compile assets'
  task compile: :environment do
    Dir.chdir("#{Rails.root}/vendor") do
      compile_strategy = 'start'
      compile_strategy = 'start:prod' if Rails.env.production?
      system('npm', compile_strategy)
    end
  end
end