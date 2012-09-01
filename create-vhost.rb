#  Create Apache vHost On Mac
#  Copyright (C) 2012  John Graham http://www.johngraham.me
#    
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'fileutils'
require 'socket'

# get local ip to pass along to xip.io (wildcard DNV) 
# http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
def local_ip
  orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true  # turn off reverse DNS resolution temporarily
  UDPSocket.open do |s|
    s.connect '64.233.187.99', 1
    s.addr.last
  end
ensure
  Socket.do_not_reverse_lookup = orig
end

# exit if too few arguments are passed
if ARGV.length < 2 
	exit
end

# domain path is the folder you want your vhost to point to 
domainPath = ARGV[0]
# domain slug is the name for your domain
domainSlug = ARGV[1]
localIP = local_ip

if File.exist? "/etc/hosts" # <-- change to path of hosts file if different
	#make backup of host file
	FileUtils.cp("/etc/hosts", "/etc/hosts.bak")

	open("/etc/hosts", 'a') do |f|
		# add entries for new vhost in hosts file (change .dev to your preferred TLD)
		f.puts "127.0.0.1\t#{domainSlug}.dev #{domainSlug}.#{localIP}.xip.io"
	end

else
	puts "Host file doesn't exist"
	exit
end

if File.exist? "/etc/apache2/extra/httpd-vhosts.conf" # <-- change to path of apache vhost file if different
	#make backup of vhost file
	FileUtils.cp("/etc/apache2/extra/httpd-vhosts.conf", "/etc/apache2/extra/httpd-vhosts.conf_bak")

	open("/etc/apache2/extra/httpd-vhosts.conf", 'a') do |f|
		f.puts "\n<VirtualHost *:80>"
		f.puts "\tDocumentRoot \"#{domainPath}\""
		f.puts "\tServerName #{domainSlug}.dev" # <- change .dev to your preferred TLD
		f.puts "\tServerAlias #{domainSlug}.#{localIP}.xip.io" # for http://xip.io wildcard dns
		f.puts "\t<Directory \"#{domainPath}\">"
		# -- Optional Options -- #
		#f.puts "\t\tOptions Indexes FollowSymLinks MultiViews"
		#f.puts "\t\tAllowOverride All"
		#f.puts "\t\tOrder allow,deny"
		#f.puts "\t\tallow from all"
		f.puts "\t</Directory>"
		f.puts "</VirtualHost>"
		
		# restart apache (you may need to change this command to match your setup)
		system('sudo -S /usr/sbin/apachectl restart')
	end

else
	puts "vhost file doesn't exist"
	exit
end
