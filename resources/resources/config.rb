# Cookbook Name:: nginx
#
# Resource:: config
#

actions :add, :add_s3, :add_erchef, :configure_certs, :remove, :register, :deregister
default_action :add

attribute :user, :kind_of => String, :default => "nginx"
attribute :s3_port, :kind_of => Integer, :default => 9000
attribute :erchef_port, :kind_of => Integer, :default => 4443
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :service_name, :kind_of => String
