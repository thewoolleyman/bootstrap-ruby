Bootstrap Ruby
==============

Chad Woolley - [http://thewoolleyweb.com](http://thewoolleyweb.com) - [http://pivotallabs.com](http://pivotallabs.com)

[http://github.com/thewoolleyman/bootstrap-ruby](http://github.com/thewoolleyman/bootstrap-ruby)

SUMMARY:
--------
  
* Simple script to install and configure various versions of Ruby from scratch on bare-bones machines.
* Watch the Cinabox Screencast to see bootstrap ruby in action: [http://s3.amazonaws.com/assets.pivotallabs.com/99/original/cinabox_screencast.mov](http://s3.amazonaws.com/assets.pivotallabs.com/99/original/cinabox_screencast.mov)


DESCRIPTION:
------------

* Bootstrap Ruby is a script to set up Ruby and other useful packages on
  a bare-bones box.  Bootstrap Ruby is only tested on the latest Ubuntu.
  It may work on other Debian-based systems. If it doesn't work, fix it or 
  try running the commands manually - the scripts are intended to
  be easily readable and easily changed.
* Support: [http://thewoolleyweb.lighthouseapp.com/projects/32917-bootstrap-ruby](http://thewoolleyweb.lighthouseapp.com/projects/32917-bootstrap-ruby)

REQUIREMENTS:
-------------

* Ubuntu and an internet connection

INSTRUCTIONS:
-------------

* DISCLAIMER: Bootstrap Ruby is intended to be run on a clean/dedicated system.  If you
  run it on an existing system, it may blow away some existing configuration. 
* Install Ubuntu, manually or as a virtual machine:
  * http://www.ubuntu.com/getubuntu/download
  * VMWare Player (win): http://www.vmware.com/products/player/
  * VMWare Fusion (mac): http://www.vmware.com/download/fusion/
  * Ubuntu VMWare image: 
    * Here's one: http://symbiosoft.net/UbuntuServerMinimalVA
    * Or search for an "Ubuntu" Operating System VMs that works for you:
      http://www.vmware.com/appliances/directory/cat/45
    * 7-Zip archiver: http://www.7-zip.org/ ('7za x <file>' to extract) 
* Log in
* wget http://github.com/thewoolleyman/bootstrap-ruby/tarball/master
* tar -zxvf thewoolleyman-bootstrap-ruby-[COMMIT_ID].tar.gz
* cd thewoolleyman-bootstrap-ruby-[COMMIT_ID]
* ./bootstrap_ruby.sh
* You can also install a specific version of ruby:
  * RUBY\_VERSION=1.8.6-p287 ./bootstrap_ruby.sh
* Ensure Ruby got installed by typing 'ruby --version'
* Review the output.  If there were errors, fix and rerun './bootstrap_ruby.sh'.
  Pass the '--force' param to redo already-completed steps
* For help with bootstrap-ruby, open a ticket:
  http://thewoolleyweb.lighthouseapp.com/projects/32917-bootstrap-ruby

LICENSE:
--------

(The MIT License)

Copyright (c) 2009 Chad Woolley

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
