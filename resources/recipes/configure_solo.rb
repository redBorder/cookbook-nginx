# Cookbook:: nginx
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

nginx_config 'config' do
  service_name 's3'
  action [:add, :configure_certs]
end
