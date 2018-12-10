curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
source /home/cmrdash/.rvm/scripts/rvm
rvm requirements
rvm reload
rvm install 2.5
rvm use 2.5 --default
rvm rubygems current
gem install rails
gem install bundler
