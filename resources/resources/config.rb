# Cookbook Name:: nginx
#
# Resource:: config
#

actions :add, :remove, :register, :deregister
default_action :add

attribute :user, :kind_of => String, :default => "nginx"
attribute :webui_port, :kind_of => Integer, :default => 8001
attribute :cdomain, :kind_of => String, :default => "redborder.cluster"
attribute :nginx_cert, :kind_of => [TrueClass, FalseClass], :default => false



# EXAMPLES

#attribute :myinteger, :kind_of => Fixnum, :default => 1
#attribute :myarray, :kind_of => Array, :default => ["val1"]
#attribute :myhash, :kind_of => Object, :default => {"val1" => "1"}
#attribute :myboolean, :kind_of => [TrueClass, FalseClass], :default => true
