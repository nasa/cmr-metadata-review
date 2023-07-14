FROM centos:centos8
USER root

# Setup mirror list
RUN cd /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install base packages
RUN yum install -y epel-release
RUN yum clean metadata
RUN yum install -y bzip2 \
                   cmake \
                   https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm \
                   chromedriver \
                   https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
                   git gcc gcc-c++ \
                   ImageMagick \
                   java-11-openjdk-headless.x86_64 \
                   liberation-fonts \
                   libffi-devel \
                   libicu-devel \
                   libxml2-devel \
                   make \
                   openssl-devel \
                   readline-devel \
                   sqlite-devel \
                   tar \
                   which \
                   xorg-x11-server-Xvfb \
                   docker

# Setup Node v18 and Yarn
RUN curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo
RUN yum install -y gcc-c++ make
RUN yum install -y nodejs && yum clean all
RUN yum install -y yarn

ENV JAVA_HOME /etc/alternatives/jre


# Install Ruby from source
WORKDIR /
RUN curl -OL https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.6.tar.gz \
 && tar -xzf ruby-3.0.6.tar.gz \
 && rm ruby-3.0.6.tar.gz \
 && cd /ruby-3.0.6 \
 && ./configure --enable-shared --disable-install-doc \
 && make -j $(nproc) \
 && make install \
 && cd / \
 && rm -fr ruby-3.0.6

# Install PostgreSQL
RUN dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
RUN dnf -y module -y disable postgresql
RUN dnf clean all
ENV PATH=/home/bamboo/.gem/ruby/3.0.6/bin:/usr/pgsql-11/bin:/opt/google/chrome/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN gem install bundler --version 2.2.33 --user-install
RUN gem install rspec --version=3.12 --user-install
RUN gem install debase --version=0.2.5.beta2 --user-install
RUN groupadd -g 500 bamboo
RUN useradd --gid bamboo --create-home --uid 500 bamboo
RUN dnf --enablerepo=powertools install perl-IPC-Run -y
RUN dnf install -y postgresql11-devel

# Setup bamboo
USER bamboo
WORKDIR /build
ENV HOME /home/bamboo
ENV NODE_OPTIONS --openssl-legacy-provider
