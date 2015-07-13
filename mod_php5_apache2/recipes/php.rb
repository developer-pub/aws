#Let AWS Opsworks download from Git and deploy to /srv
include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end
end

# setup Apache virtual host
node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping mod_php5_apache2::php application #{application} as it is not an PHP app")
    next
  end

  application_name = deploy[:application]

  parameters = {}
  parameters[:docroot] = deploy[:absolute_document_root]
  parameters[:server_name] = deploy[:domains].first
  unless deploy[:domains][1, deploy[:domains].size].empty?
    parameters[:server_aliases] = deploy[:domains][1, deploy[:domains].size]
  end
  parameters[:mounted_at] = deploy[:mounted_at]
  parameters[:ssl_certificate_ca] = deploy[:ssl_certificate_ca]

  template "/etc/httpd/conf.d/zzz-application.conf" do
    source 'web_app.conf.erb'
    local false
    owner 'root'
    group 'root'
    mode '0644'

    environment_variables = if node[:deploy][application_name].nil?
                              {}
                            else
                              node[:deploy][application_name][:environment_variables]
                            end

    variables(
      :application_name => application_name,
      :params           => parameters,
      :environment => OpsWorks::Escape.escape_double_quotes(environment_variables)
    )
  end

  template "/etc/httpd/ssl/#{deploy[:domains].first}.crt" do
    mode 0600
    source 'ssl.key.erb'
    variables :key => deploy[:ssl_certificate]
    only_if do
      deploy[:ssl_support]
    end
  end

  template "/etc/httpd/ssl/#{deploy[:domains].first}.key" do
    mode 0600
    source 'ssl.key.erb'
    variables :key => deploy[:ssl_certificate_key]
    only_if do
      deploy[:ssl_support]
    end
  end

  template "/etc/httpd/ssl/#{deploy[:domains].first}.ca" do
    mode 0600
    source 'ssl.key.erb'
    variables :key => deploy[:ssl_certificate_ca]
    only_if do
      deploy[:ssl_support] && deploy[:ssl_certificate_ca]
    end
  end

  # template "#{node[:apache][:dir]}/ssl/#{deploy[:domains].first}.crt" do
  #   mode 0600
  #   source 'ssl.key.erb'
  #   variables :key => deploy[:ssl_certificate]
  #   notifies :restart, "service[apache2]"
  #   only_if do
  #     deploy[:ssl_support]
  #   end
  # end

  # template "#{node[:apache][:dir]}/ssl/#{deploy[:domains].first}.key" do
  #   mode 0600
  #   source 'ssl.key.erb'
  #   variables :key => deploy[:ssl_certificate_key]
  #   notifies :restart, "service[apache2]"
  #   only_if do
  #     deploy[:ssl_support]
  #   end
  # end

  # template "#{node[:apache][:dir]}/ssl/#{deploy[:domains].first}.ca" do
  #   mode 0600
  #   source 'ssl.key.erb'
  #   variables :key => deploy[:ssl_certificate_ca]
  #   notifies :restart, "service[apache2]"
  #   only_if do
  #     deploy[:ssl_support] && deploy[:ssl_certificate_ca]
  #   end
  # end
end

#Stop Apache
execute "Stop Apache" do
  command "sleep 3 && /sbin/service httpd stop && sleep 3"
end

#Start Apache
execute "Restart Apache" do
  command "sleep 3 && /sbin/service httpd restart && sleep 3"
end
