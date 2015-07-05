execute "Add newrelic repository" do
  command "rpm -Uvh http://download.newrelic.com/pub/newrelic/el5/i386/newrelic-repo-5-3.noarch.rpm"
  creates "/etc/yum.repos.d/newrelic.repo"
end

execute "yum install -y newrelic-sysmond"

execute "Newrelic config" do
  command "/usr/sbin/nrsysmond-config --set license_key=#{node['newrelic']['key']}"
end

ENV['NR_INSTALL_SILENT'] = "1"
ENV['NR_INSTALL_KEY'] = "#{node['newrelic']['key']}"

service "newrelic-sysmond" do
    supports :status => true, :start => true, :stop => true, :restart => true
    action [:enable, :start]
end
