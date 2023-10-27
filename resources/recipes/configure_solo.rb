#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2017, redborder
#
# All rights reserved - Do Not Redistribute
#

nginx_config "config" do
  service_name "s3"
  action [:add, :configure_certs, :add_s3]
end
