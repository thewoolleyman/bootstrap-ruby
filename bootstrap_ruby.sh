#!/bin/bash
# http://github.com/thewoolleyman/bootstrap-ruby
# This script is tested on Ubuntu Linux, but it should run on most Debian distros

# Install build prerequisites
which emerge
if [ $? = 0 ]; then
  # Gentoo
  DISTRO='gentoo'
  sudo emerge zlib # TODO: Add other libs required on a clean gentoo distro
else
  # Debian
  DISTRO='debian'
  sudo aptitude update
  sudo aptitude install -y build-essential zlib1g zlib1g-dev libssl-dev openssl libreadline5-dev openssh-server openssh-client ssh wget
fi

# Set default options with allowed overrides
# Current ruby versions: 1.8.6-p287, 1.8.7-p72, 1.9.1-p243
DEFAULT_RUBY_VERSION=1.8.6-p287
if [ -z $RUBY_VERSION ]; then RUBY_VERSION=$DEFAULT_RUBY_VERSION; fi
RUBY_MINOR_VERSION=${RUBY_VERSION:0:3}
RUBY_TEENY_VERSION=${RUBY_VERSION:0:5}

# Rubygems currently has issues correctly handling prefix and program-suffix.  Gem executables will not be
# found correctly or put on the path, so turn off prefix and suffix unless they are explicitly specified.
if [ -z $RUBY_PREFIX ]; then NO_RUBY_PREFIX=true; fi
if [ -z $RUBY_PROGRAM_SUFFIX ]; then NO_RUBY_PROGRAM_SUFFIX=true; fi

# Set a default RUBY_PREFIX and RUBY_PROGRAM_SUFFIX unless NO_RUBY_PREFIX or NO_RUBY_PROGRAM_SUFFIX are set
if [ -z $NO_RUBY_PREFIX ]; then
  if [ -z $RUBY_PREFIX ]; then RUBY_PREFIX=/usr/local/lib/ruby$RUBY_TEENY_VERSION; fi
fi
if [ -z $NO_RUBY_PROGRAM_SUFFIX ]; then
  if [ -z $RUBY_PROGRAM_SUFFIX ]; then RUBY_PROGRAM_SUFFIX=$RUBY_TEENY_VERSION; fi
fi

if [ -z $BUILD_DIR ]; then export BUILD_DIR=~/.bootstrap-ruby; fi

if [ $RUBY_TEENY_VERSION = '1.8.7' ] || [ "$FORCE_RUBY_UNINSTALL" = 'true' ]; then 
  # Remove existing Debian ruby installation, because otherwise rubygems won't work under source install of 1.8.7
  # Sorry if this breaks you, caveat emptor
  FORCE_RUBY_UNINSTALL = 'true'
fi

if [ "$FORCE_RUBY_UNINSTALL" = 'true' ]; then
  if [ "$DISTRO" = 'gentoo']; then 
    # Remove existing Gentoo ruby installation
    sudo emerge -C ruby
  else
    sudo aptitude remove -y ruby ruby1.8 libruby1.8
  fi
fi

# Make build dir
mkdir -p $BUILD_DIR
cd $BUILD_DIR

function install_ruby {
  # Download and unpack Ruby distribution
  sudo rm -f ruby-$RUBY_VERSION.tar.gz
  wget ftp://ftp.ruby-lang.org/pub/ruby/$RUBY_MINOR_VERSION/ruby-$RUBY_VERSION.tar.gz
  sudo rm -f ruby-$RUBY_VERSION
  tar -zxvf ruby-$RUBY_VERSION.tar.gz

  # Update extensions Setup by deleting “Win” lines (Win32API and win32ole) and uncommenting all other lines
  if [ ! -e ruby-$RUBY_VERSION/ext/Setup.orig ]; then cp ruby-$RUBY_VERSION/ext/Setup ruby-$RUBY_VERSION/ext/Setup.orig; fi
  sudo rm -f /tmp/Setup.new
  cat ruby-$RUBY_VERSION/ext/Setup.orig | grep -iv 'win' | grep -iv 'nodynamic' | sed -n -e 's/#\(.*\)/\1/p' > /tmp/Setup.new
  sudo rm -f /tmp/Setup
  cp /tmp/Setup.new ruby-$RUBY_VERSION/ext/Setup

  # Configure, make, and install
  cd $BUILD_DIR/ruby-$RUBY_VERSION

  # Apply patch required for Ruby 1.8.7-p72 - see http://redmine.ruby-lang.org/issues/show/863
  if [ $RUBY_VERSION = '1.8.7-p72' ]; then 
    cat ext/openssl/ossl_digest.c | grep -v 'rb_require("openssl")' > ext/openssl/ossl_digest.c.patched
    cp ext/openssl/ossl_digest.c.patched ext/openssl/ossl_digest.c
  fi

  # Configure with options
  if [ $RUBY_MINOR_VERSION = 1.8 ]; then VERSION_OPTS=--disable-pthreads; else VERSION_OPTS=; fi
  if [ ! -z $RUBY_PREFIX ]; then 
    PREFIX_OPT="--prefix=$RUBY_PREFIX"
  fi
  if [ ! -z $RUBY_PROGRAM_SUFFIX ]; then 
    PROGRAM_SUFFIX_OPT="--program-suffix=$RUBY_PROGRAM_SUFFIX"
  fi
  ./configure $VERSION_OPTS $PREFIX_OPT $PROGRAM_SUFFIX_OPT

  # Make and install
  make
  if [ ! $? = 0 ]; then echo "error running 'make'" && exit 1; fi
  sudo rm -rf .ext/rdoc
  sudo make install
  if [ ! $? = 0 ]; then echo "error running 'sudo make install'" && exit 1; fi

  # Make symlinks for all executables
  sudo ln -sf `cd $RUBY_PREFIX && pwd`/bin/* /usr/local/bin

  # Make symlink at /usr/bin/ruby, so init scripts can be written in ruby
  sudo ln -sf /usr/local/bin/ruby /usr/bin/ruby
  # Make symlink at /bin/ruby, in case there was already one there or something wants it there
  sudo ln -sf /usr/local/bin/ruby /bin/ruby

  # Set up alternatives entry
  # To pick from multiple rubies interactively, use 'sudo update-alternatives --config ruby'
  sudo update-alternatives --install \
   /usr/local/bin/ruby ruby $RUBY_PREFIX/bin/ruby$RUBY_PROGRAM_SUFFIX 100 \
   --slave /usr/local/bin/erb erb $RUBY_PREFIX/bin/erb$RUBY_PROGRAM_SUFFIX \
   --slave /usr/local/bin/gem gem $RUBY_PREFIX/bin/gem$RUBY_PROGRAM_SUFFIX \
   --slave /usr/local/bin/irb irb $RUBY_PREFIX/bin/irb$RUBY_PROGRAM_SUFFIX \
   --slave /usr/local/bin/rdoc rdoc $RUBY_PREFIX/bin/rdoc$RUBY_PROGRAM_SUFFIX \
   --slave /usr/local/bin/ri ri $RUBY_PREFIX/bin/ri$RUBY_PROGRAM_SUFFIX \
   --slave /usr/local/bin/testrb testrb $RUBY_PREFIX/bin/testrb$RUBY_PROGRAM_SUFFIX

  # Set default alternative to the one we just installed 
  sudo update-alternatives --set ruby $RUBY_PREFIX/bin/ruby$RUBY_PROGRAM_SUFFIX
}

# Do not reinstall same version unless INSTALL_RUBY_FORCE is passed
EXISTING_RUBY_VERSION=`ruby --version`
EXISTING_RUBY_TEENY_VERSION=`echo ${EXISTING_RUBY_VERSION:5:5}-p${EXISTING_RUBY_VERSION:34:4} | tr -d ')'`
if [ $RUBY_VERSION = $EXISTING_RUBY_TEENY_VERSION ] && [ -z $INSTALL_RUBY_FORCE ]; then
  echo "Ruby version $EXISTING_RUBY_TEENY_VERSION is already installed.  Prepend RUBY_VERSION=x.y.z-p123 for a specific version, or INSTALL_RUBY_FORCE=true to reinstall $DEFAULT_RUBY_VERSION"
  EXISTING_RUBY_EXEC=`which ruby`
  CANONICAL_RUBY_EXEC=`readlink -f $EXISTING_RUBY_EXEC`
  RUBY_BINDIR=${CANONICAL_RUBY_EXEC%ruby*}
  RUBY_PROGRAM_SUFFIX=${CANONICAL_RUBY_EXEC##*ruby}
else
  install_ruby
  CANONICAL_RUBY_EXEC=$RUBY_PREFIX/bin/ruby$RUBY_PROGRAM_SUFFIX
  RUBY_BINDIR=$RUBY_PREFIX/bin
  # Always reinstall rubygems if we installed ruby
  INSTALL_RUBYGEMS_FORCE='true'
fi

function install_rubygems {
  # Download and install RubyGems - TODO: is there an easy way to automate the mirror and version?
  if [ -z $RUBYGEMS_MIRROR_ID ]; then RUBYGEMS_MIRROR_ID=60718; fi
  if [ -z $RUBYGEMS_VERSION ]; then RUBYGEMS_VERSION=1.3.5; fi
  cd $BUILD_DIR
  rm -r rubygems-$RUBYGEMS_VERSION.tgz
  wget http://rubyforge.org/frs/download.php/$RUBYGEMS_MIRROR_ID/rubygems-$RUBYGEMS_VERSION.tgz
  rm -r rubygems-$RUBYGEMS_VERSION
  tar -zxvf rubygems-$RUBYGEMS_VERSION.tgz
  cd $BUILD_DIR/rubygems-$RUBYGEMS_VERSION
  sudo $CANONICAL_RUBY_EXEC setup.rb
  if [ ! $? = 0 ]; then echo "error building rubygems" && exit 1; fi
}

# Do not reinstall rubygems unless INSTALL_RUBYGEMS_FORCE is passed
which gem$RUBY_PROGRAM_SUFFIX
if [ $? = 0 ] && [ -z $INSTALL_RUBYGEMS_FORCE ]; then
  echo "Rubygems is already installed at `which gem$RUBY_PROGRAM_SUFFIX`.  Prepend INSTALL_RUBYGEMS_FORCE=true to reinstall"
else
  install_rubygems
fi
# if it doesn't already exist, make a 'gem' symlink with no suffix in the same location as the ruby executable, 
# because RubyGems will (currently) format the executable with RUBY_PROGRAM_SUFFICX, and not create a 'gem' exec by default
if [ ! -e $RUBY_BINDIR/gem ]; then sudo ln -sf $RUBY_BINDIR/gem$RUBY_PROGRAM_SUFFIX $RUBY_BINDIR/gem; fi  

# Warn user about path if prefix is not default (/usr/local/bin)
if [ ! -z $RUBY_PREFIX ]; then 
  echo; echo;
  echo "Please put $RUBY_PREFIX/bin on your path or gem executables may not be found."
  echo; echo;
fi

# DEBUGGING OUTPUT FOR NOW
echo; echo;
echo "RUBY_VERSION = '$RUBY_VERSION'"
echo "EXISTING_RUBY_TEENY_VERSION = '$EXISTING_RUBY_TEENY_VERSION'"
echo "RUBY_PREFIX = '$RUBY_PREFIX'"
echo "RUBY_PROGRAM_SUFFIX = '$RUBY_PROGRAM_SUFFIX'"
echo "RUBY_BINDIR = '$RUBY_BINDIR'"
echo "CANONICAL_RUBY_EXEC = '$CANONICAL_RUBY_EXEC'"
echo "EXISTING_RUBY_EXEC = '$EXISTING_RUBY_EXEC'"

