#!/usr/bin/env bash

cd /tmp

VERSION_REGEX="CentOS release ([[:digit:]])"
OS_VERSION=$(cat /etc/redhat-release)

[[ $OS_VERSION =~ $VERSION_REGEX ]]
VERSION="${BASH_REMATCH[1]}"

if [[ $VERSION == 5 ]]
then
  wget http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
  rpm -ivh epel-release-5-4.noarch.rpm
elif [[ $VERSION == 6 ]]
then
  wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
  rpm -Uvh epel-release-6-8.noarch.rpm
elif [[ $VERSION == 7 ]]
then
  wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
  rpm -ivh epel-release-7-5.noarch.rpm
else
  echo "Unhandled Version: ${VERSION}"
  exit 1
fi

# system update
yum -y update
yum -y groupinstall "Development Tools"

DEV_PACKAGES=(db4-devel gdbm-devel git libffi-devel libxml2-devel libxslt-devel libyaml libyaml-devel memcached-devel ncurses-devel openssl-devel pcre-devel readline-devel tcl-devel valgrind-devel zlib-devel)
DB_PACKAGES=(sqlite3-devel mysql-devel)
EXTRA_PACKAGES=(ImageMagick-devel ImageMagick)

yum --enablerepo=epel -y install ${DEV_PACKAGES[*]}
yum --enablerepo=epel -y install ${DB_PACKAGES[*]}
yum --enablerepo=epel -y install ${EXTRA_PACKAGES[*]}

#for pack in ${DEV_PACKAGES[@]}; do
    #yum --enablerepo=epel -y install $pack
#done

# ruby 2.2.2
RB_VERSION=2.2.2
cd /usr/local/src
wget ftp://ftp.ruby-lang.org/pub/ruby/2.2/ruby-$RB_VERSION.tar.gz
tar zxvf ruby-$RB_VERSION.tar.gz
cd ruby-$RB_VERSION
./configure
make
make install

# ruby-gems
#GEM_VERSION=2.2.0
#cd ..
#wget http://rubyforge.org/frs/download.php/69365/rubygems-$GEM_VERSION.tgz
#tar -zxvf rubygems-$GEM_VERSION.tgz
#cd rubygems-$GEM_VERSION
#/usr/local/bin/ruby setup.rb
touch /etc/gemrc
echo "gem: --no-rdoc --no-ri" > /etc/gemrc
#sudo sh -c 'echo "gem: --no-rdoc --no-ri" > /etc/gemrc'
#sudo gem update
#sudo gem update --system
sudo env "PATH=$PATH" gem update
sudo env "PATH=$PATH" gem update --system
