# Set up the permissions

node[:deploy].each do |application, deploy|
  templates_dir = "#{deploy[:deploy_to]}/current/smarty/templates_c"
  execute "chmod 777 #{templates_dir}" do
  end
end

node[:deploy].each do |application, deploy|
  brackets_dir = "#{deploy[:deploy_to]}/current/public/brackets"
  execute "chmod -R 777 #{brackets_dir}" do
  end
end
