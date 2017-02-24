#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2017, redborder
#
# All rights reserved - Do Not Redistribute
#

nginx_config "config" do
  service_name "test"
  action [:add, :configure_certs]
end
