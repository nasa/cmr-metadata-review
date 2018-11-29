####################################
# Install Centos 7                 #
####################################
FROM centos:7
RUN yum install -y git-core zlib zlib-devel gcc-c++ \
                   patch readline readline-devel libyaml-devel libffi-devel \
                   openssl-devel make bzip2 autoconf automake libtool bison \
                   sqlite-devel libxslt-devel libxml2-devel postgresql-libs \
                   postgresql-devel postgresql-server postgresql-contrib \
                   curl which git java-1.8.0-openjdk gnupg2 

RUN curl -sL https://rpm.nodesource.com/setup_6.x | bash -
RUN yum install -y nodejs
RUN useradd -ms /bin/bash cmrdash

####################################
# Install Ruby                     #
####################################
RUN mkdir /scripts
ADD scripts/install_ruby.sh /scripts

####################################
# Create DB Users                  #
####################################
ADD scripts/install_db.sh /scripts
ADD scripts/create_user.sh /scripts
ADD scripts/create_db.sh /scripts
ADD .pgpass /root
RUN chmod 0600 /root/.pgpass
RUN chmod g-r /root/.pgpass
RUN chmod o-r /root/.pgpass

####################################
# Install CmrDash Source           #
####################################


RUN /scripts/install_db.sh
USER cmrdash
RUN bash -l /scripts/install_ruby.sh
WORKDIR /home/cmrdash/cmr-metadata-review
CMD tail -f /dev/null
#CMD ["bash", "-l"]

