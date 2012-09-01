#Create Apache Vhosts On Mac

Ruby script to create an Apache vhost on a Mac and add an entry to host file.

This script will make a backup of your host file and vhost file, add a vhost for the specified domain and destination path, create the appropriate entry in your hosts file.

A server alias and hosts record are also setup to take advantage of [xip.io][a] wildcard DNS.  This takes the form of  `http://domain.yourip.xip.io`.

*Note: Only one backup is made of each file.  If a backup already exists, it will be overwritten*

## Usage
- Edit script with the correct path to your hosts file and vhost file.
- Optionally change the TLD for the domain.
- Optionally adjust the configuration options of the vhost record
- Execute the script:
	`[sudo] ruby create-vhost.rb /path/to/site/ domain_slug`

[a]: http:xip.io