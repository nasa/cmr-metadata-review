# https://rvm.io/rvm/install
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -L get.rvm.io | bash -s stable
source /home/cmrdash/.rvm/scripts/rvm
rvm requirements
rvm reload
rvm install 2.5
rvm use 2.5 --default
rvm rubygems current
gem install rails
gem install bundler
