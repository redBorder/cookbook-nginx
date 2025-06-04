# Cookbook:: nginx
# Provider:: config

include Nginx::Helper

action :add do
  begin
    user = new_resource.user

    dnf_package 'nginx' do
      action :upgrade
      flush_cache [:before]
    end

    execute 'create_user' do
      command '/usr/sbin/useradd -r nginx'
      ignore_failure true
      not_if 'getent passwd nginx'
    end

    %w( /var/www /var/www/cache /var/log/nginx /etc/nginx/ssl /etc/nginx/conf.d ).each do |path|
      directory path do
        owner user
        group user
        mode '0755'
        action :create
      end
    end

    # generate nginx config
    template '/etc/nginx/nginx.conf' do
      source 'nginx.conf.erb'
      owner user
      group user
      mode '0644'
      cookbook 'nginx'
      variables(user: user)
      notifies :restart, 'service[nginx]'
    end

    service 'nginx' do
      service_name 'nginx'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:start, :enable]
    end

    Chef::Log.info('Nginx cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :configure_certs do
  begin
    user = new_resource.user
    cdomain = new_resource.cdomain
    service_name = new_resource.service_name

    json_cert = nginx_certs(service_name, cdomain)

    template "/etc/nginx/ssl/#{service_name}.crt" do
      source 'cert.crt.erb'
      owner user
      group user
      mode '0644'
      retries 2
      cookbook 'nginx'
      not_if { json_cert.empty? }
      variables(crt: json_cert["#{service_name}_crt"])
      action :create
    end

    template "/etc/nginx/ssl/#{service_name}.key" do
      source 'cert.key.erb'
      owner user
      group user
      mode '0644'
      retries 2
      cookbook 'nginx'
      not_if { json_cert.empty? }
      variables(key: json_cert["#{service_name}_key"])
      action :create
    end

    Chef::Log.info("Nginx cookbook - Certs for service #{service_name} has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :add_http2k do
  begin
    user = new_resource.user
    http2k_hosts = new_resource.http2k_hosts
    http2k_port = new_resource.http2k_port

    service 'nginx' do
      service_name 'nginx'
      supports status: true, reload: true, restart: true, start: true, enable: true
      action :nothing
    end

    template '/etc/nginx/conf.d/http2k.conf' do
      source 'http2k.conf.erb'
      owner user
      group user
      mode '0644'
      cookbook 'nginx'
      variables(http2k_hosts: http2k_hosts, http2k_port: http2k_port)
      notifies :restart, 'service[nginx]'
    end

    Chef::Log.info('nginx http2k configuration has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :add_s3 do # Only for configure solo
  begin
    user = new_resource.user
    s3_port = new_resource.s3_port
    s3_hosts = new_resource.s3_hosts
    cdomain = get_cdomain

    template '/etc/nginx/conf.d/s3.conf' do
      source 's3.conf.erb'
      owner user
      group user
      mode '0644'
      cookbook 'nginx'
      variables(s3_hosts: s3_hosts, s3_port: s3_port, cdomain: cdomain)
      notifies :restart, 'service[nginx]'
    end

    service 'nginx' do
      service_name 'nginx'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:nothing]
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :add_erchef do
  begin
    user = new_resource.user
    erchef_hosts = new_resource.erchef_hosts
    erchef_port = new_resource.erchef_port

    template '/etc/nginx/conf.d/erchef.conf' do
      source 'erchef.conf.erb'
      owner user
      group user
      mode '0644'
      cookbook 'nginx'
      variables(erchef_hosts: erchef_hosts, erchef_port: erchef_port)
      notifies :restart, 'service[nginx]'
    end

    service 'nginx' do
      service_name 'nginx'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:nothing]
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :add_aioutliers do
  begin
    user = new_resource.user
    aioutliers_hosts = new_resource.aioutliers_hosts
    aioutliers_port = new_resource.aioutliers_port

    template '/etc/nginx/conf.d/aioutliers.conf' do
      source 'aioutliers.conf.erb'
      owner user
      group user
      mode '0644'
      cookbook 'nginx'
      variables(aioutliers_hosts: aioutliers_hosts, aioutliers_port: aioutliers_port)
      notifies :restart, 'service[nginx]'
    end

    service 'nginx' do
      service_name 'nginx'
      ignore_failure true
      supports status: true, reload: true, restart: true, enable: true
      action [:nothing]
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service 'nginx' do
      service_name 'nginx'
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    Chef::Log.info('Nginx cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove_http2k do
  begin

    service 'nginx' do
      service_name 'nginx'
      supports status: true, reload: true, restart: true, start: true, enable: true
      action :nothing
    end

    file '/etc/nginx/conf.d/http2k.conf' do
      action :delete
      notifies :restart, 'service[nginx]'
    end

    Chef::Log.info('nginx http2k configuration has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove_aioutliers do
  begin

    service 'nginx' do
      service_name 'nginx'
      supports status: true, reload: true, restart: true, start: true, enable: true
      action :nothing
    end

    file '/etc/nginx/conf.d/aioutliers.conf' do
      action :delete
      notifies :restart, 'service[nginx]'
    end

    Chef::Log.info('nginx aioutliers configuration has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    consul_servers = system('serf members -tag consul=ready | grep consul=ready &> /dev/null')
    unless node['nginx']['registered'] && consul_servers
      query = {}
      query['ID'] = "nginx-#{node['hostname']}"
      query['Name'] = 'nginx'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 443
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        retries 3
        retry_delay 2
        action :nothing
      end.run_action(:run)

      node.normal['nginx']['registered'] = true
      Chef::Log.info('Nginx service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    consul_servers = system('serf members -tag consul=ready | grep consul=ready &> /dev/null')
    if node['nginx']['registered'] && consul_servers
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/nginx-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['nginx']['registered'] = false
      Chef::Log.info('Nginx service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
