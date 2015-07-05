#Packages to be installed
default[:mod_php5_apache2][:packages] = [
    "php55-xml",
    "php55-common",
    "php55-xmlrpc",
    "php55-gd",
    "php55-cli",
    "php-pear-Auth-SASL",
    "php55-mcrypt",
    "php55-pecl-memcache",
    "php-pear",
    "php-pear-XML-Parser",
    "php-pear-DB",
    "php-pear-HTML-Common",
    "php55",
    "php55-devel",
    "php-pear-Mail-Mime"
]

#We remove everything (even Apache 2.4) to start with clean state
default[:mod_php5_apache2][:packages_remove] = [
    "php-xml",
    "php-common",
    "php-xmlrpc",
    "php-gd",
    "php-cli",
    "php-pear-Auth-SASL",
    "php-mcrypt",
    "php-pecl-memcache",
    "php-pear",
    "php-pear-XML-Parser",
    "php-pear-DB",
    "php-pear-HTML-Common",
    "php",
    "php-devel",
    "php-pear-Mail-Mime",
    "httpd",
    "httpd-tools",

    "php55-xml",
    "php55-common",
    "php55-xmlrpc",
    "php55-gd",
    "php55-cli",
    "php55-mcrypt",
    "php55-pecl-memcache",
    "php55",
    "php55-devel",
    "httpd24",
    "httpd24-tools"
]
