# Cookbook:: nginx
# Resource:: config

actions :add, :add_http2k, :add_s3, :add_erchef, :add_aioutliers, :configure_certs, :remove_http2k, :remove_aioutliers, :remove, :register, :deregister
default_action :add

attribute :user, kind_of: String, default: 'nginx'
attribute :http2k_port, kind_of: Integer, default: 9000
attribute :http2k_hosts, kind_of: Array
attribute :s3_port, kind_of: Integer, default: 7980
attribute :s3_hosts, kind_of: Array, default: ['localhost:9000']
attribute :erchef_hosts, kind_of: Array
attribute :erchef_port, kind_of: Integer, default: 4443
attribute :aioutliers_hosts, kind_of: Array
attribute :aioutliers_port, kind_of: Integer, default: 39091
attribute :cdomain, kind_of: String, default: 'redborder.cluster'
attribute :service_name, kind_of: String
