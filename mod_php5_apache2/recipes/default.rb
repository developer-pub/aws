#We clean everything old to make sure we start clean
execute "Removing old configs" do
  command "rm -rf /etc/httpd"
end

execute "Create conf directory" do
  command "mkdir /etc/httpd"
end

execute "Create ssl directory" do
  command "mkdir /etc/httpd/ssl"
end

#We need to uninstall old php packages because they conflict with newer
node[:mod_php5_apache2][:packages_remove].each do |pkg|
  package pkg do
    action :remove
  end
end

node[:mod_php5_apache2][:packages].each do |pkg|
  package pkg do
    action :install
    ignore_failure(pkg.to_s.match(/^php-pear-/) ? true : false) # some pear packages come from EPEL which is not always available
  end
end

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end
  next if node[:deploy][application][:database].nil?

  case node[:deploy][application][:database][:type]
  when "postgresql"
    include_recipe 'mod_php5_apache2::postgresql_adapter'
  else # mysql or just backwards compatible
    include_recipe 'mod_php5_apache2::mysql_adapter'
  end
end

#Install newrelic with PHP agent
include_recipe 'newrelic::php'

execute "Restart Apache" do
  command "sleep 1 && /sbin/service httpd restart && sleep 1"
end
