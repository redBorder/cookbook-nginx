# Cookbook Name:: nginx
#
# Resource:: config
#

actions :add, :configure_certs, :add_webui, :add_s3, :remove, :register, :deregister
default_action :add

attribute :user, :kind_of => String, :default => "nginx"
attribute :webui_port, :kind_of => Integer, :default => 8001
attribute :s3_port, :kind_of => Integer, :default => 9000
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :service_name, :kind_of => String
