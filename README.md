Create Apache Vhosts On Mac
=========

Ruby script to create an Apache vhost on a Mac and add an entry to host file.

This script will make a backup of your host file and vhost file, add a vhost for the specified domain and destination path, create the appropriate entry in your hosts file.

A server alias and hosts record are also setup to take advantage of xip.io wildcard DNS.  This takes the form of  `http://domain.yourip.xip.io`.

*Note: Only one backup is made of each file.  If a backup already exists, it will be overwritten*

## Installation

Download create-vhost.rb and put it anywhere on your drive, let say in you home directory.

Add alias that helps you launch the script. Open your profile file:

    vim ~/.bash_profile

Insert this line and type :wq

    alias vhosts='sudo ruby ~/create_host.rb'

Edit the script with the correct path to your hosts file and vhost file.

Init first vhost if needed:

    vhosts init /Users/someuser/Sites

Uncomment Include /private/etc/apache2/extra/httpd-vhosts.conf in you apache config (should be found in /etc/apache2/httpd.conf)

## Usage

Create necessary vhost:

    vhosts init /Users/someuser/Sites/somedomainname

*Do not forget to create a directory for your new vhost in /Users/someuser/Sites/somedomainname*

*You can specify some extra arguments for the script*

If you wish to create a xip-io compatible vhost:

    vhosts init /Users/someuser/Sites/somedomainname true

if you wish to create a vhost with extra arguments:

    vhosts init /Users/someuser/Sites/somedomainname true true

You can remove vhost with

    vhosts remove somedomainname

## Licence

Copyright (C) 2013  Andrey Eremin http://eremin.me

Copyright (C) 2012  John Graham http://www.johngraham.me
  
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
