# Cookbook:: nginx
# Recipe:: default
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

nginx_config 'config' do
  service_name 's3'
  # before the data bags exist
  openbao node['redborder'] && node['redborder']['openbao_secrets'] == true
  action [:add, :configure_certs, :add_s3]
end
