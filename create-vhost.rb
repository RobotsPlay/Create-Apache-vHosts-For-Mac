#  Create Apache vHost On Mac
#  Copyright (C) 2013  Andrey Eremin http://eremin.me
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

HOSTS_PATH = "/etc/hosts"
VHOSTS_PATH = "/etc/apache2/extra/httpd-vhosts.conf"

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

# backup config files
def backup(file = 'hosts')
	path = (file == 'hosts' ? HOSTS_PATH : VHOSTS_PATH)
	FileUtils.cp(path, "#{path}_back") if File.exist?(path)
end

# init vhosts file with first vhost for localhost
# Pass path to Root directory with second argument
def init(path)
	backup("vhosts")
	puts 'Set up vhosts file.'
	open(VHOSTS_PATH, 'a') do |f|
		f.puts "\n###Init Part###"
		f.puts "\nListen 80"
		f.puts "\nNameVirtualHost *:80"
		f.puts "\n<VirtualHost *:80>"
		f.puts "\tDocumentRoot \"#{path}\""
		f.puts "\tServerName localhost"
		f.puts "</VirtualHost>"
		f.puts "\n###END of Init Part###"

		restart_apache
	end
	puts "Do not forget to uncomment Include derective in httpd.conf for enabling vhosts!"
end

# restart apache server
def restart_apache
	system('sudo -S /usr/sbin/apachectl restart')
end

# create vhosts
# arguments:
# path - path to Root directory
# use_xip - convert vhost's alias name to xip compatible
# full - add extra options for vhost
def create(path, use_xip = false, full = false)
	domainSlug = path.split('/').last
	localIP = local_ip

	# setting up host
	backup
    open(HOSTS_PATH, 'a') do |f|
		# add entries for new vhost in hosts file (change .dev to your preferred TLD)
		f.puts "127.0.0.1\t#{domainSlug} www.#{domainSlug} #{use_xip ? "#{domainSlug}.#{localIP}.xip.io" : ""} ### host for '#{domainSlug}'"
	end

	# setting up vhost
    backup("vhosts")    
    open(VHOSTS_PATH, 'a') do |f|
		f.puts "\n###Vhost '#{domainSlug}'###"
		f.puts "\n<VirtualHost *:80>"
		f.puts "\tDocumentRoot \"#{path}\""
		f.puts "\tServerName #{domainSlug}"
		f.puts "\tServerAlias #{domainSlug}.#{localIP}.xip.io" if use_xip
		if full
			f.puts "\t<Directory \"#{path}\">"
			f.puts "\t\tOptions Indexes FollowSymLinks MultiViews"
			f.puts "\t\tAllowOverride All"
			f.puts "\t\tOrder allow,deny"
			f.puts "\t\tallow from all"
			f.puts "\t</Directory>"
		end
		f.puts "</VirtualHost>"
		f.puts "\n###END of Vhost '#{domainSlug}'###"

		restart_apache
	end
	puts "Vhost #{domainSlug} was created. Enjoy!"
end

# remove vhost
# arguments:
# host_name - host's name
def remove(host_name)	
	# remove vhost from hosts file
	backup
	data_filterd = File.open(HOSTS_PATH).read.lines.reject{ |line| line.match('^.+(### host for \'' + host_name + '\')$') }.join('')
	File.open(HOSTS_PATH, 'w') { |f| f.write(data_filterd) }

	# remove vhost from apache vhosts file
    backup("vhosts")  
    data_filtered_arr = []
    remove = false
    start_line = '^###Vhost \'' + host_name + '\'###$'
    end_line = '^###END of Vhost \'' + host_name + '\'###$'
    File.open(VHOSTS_PATH).read.lines.each do |line|
    	remove = true if line.match(start_line)
    	remove = false if line.match(end_line)
    	data_filtered_arr << line if remove == false && !line.match(end_line)
    end
    File.open(VHOSTS_PATH, 'w') { |f| f.write(data_filtered_arr.join('')) }
    puts "Vhost #{host_name} was removed"
end

# exit if too few arguments are passed
if ARGV.length < 2
  puts "Not all arguments were supplied"	
  exit
end

# exit if config files not found
unless (File.exist?(HOSTS_PATH) && File.exist?(VHOSTS_PATH))
	puts "Cannot find config files."
	puts "Check if #{HOSTS_PATH} and #{VHOSTS_PATH} exist on your local machine."	
    exit
end

case ARGV[0]
when 'init' then init(ARGV[1])
when 'create' then create(ARGV[1],ARGV[2],ARGV[3])
when 'remove' then remove(ARGV[1])
end