
# Cookbook Name:: nginx
#
# Provider:: config
#

include Nginx::Helper

action :add do
  begin
    user = new_resource.user

    yum_package "nginx" do
      action :upgrade
      flush_cache [:before]
    end

    user user do
      action :create
      system true
    end

    %w[ /var/www /var/www/cache /var/log/nginx /etc/nginx/ssl /etc/nginx/conf.d ].each do |path|
      directory path do
        owner user
        group user
        mode 0755
        action :create
      end
    end

    # generate nginx config
    template "/etc/nginx/nginx.conf" do
      source "nginx.conf.erb"
      owner user
      group user
      mode 0644
      cookbook "nginx"
      variables(:user => user)
      notifies :restart, "service[nginx]"
    end

    service "nginx" do
      service_name "nginx"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true, :enable => true
      action [:start, :enable]
    end

    Chef::Log.info("Nginx cookbook has been processed")
  rescue => e
   Chef::Log.error(e.message)
  end

end

action :configure_certs do
  begin
    user = new_resource.user
    cdomain = new_resource.cdomain
    service_name = new_resource.service_name

    json_cert = nginx_certs(service_name,cdomain)

    template "/etc/nginx/ssl/#{service_name}.crt" do
      source "cert.crt.erb"
      owner user
      group user
      mode 0644
      retries 2
      cookbook "nginx"
      not_if {json_cert.empty?}
      variables(:crt => json_cert["#{service_name}_crt"])
      action :create
    end

    template "/etc/nginx/ssl/#{service_name}.key" do
      source "cert.key.erb"
      owner user
      group user
      mode 0644
      retries 2
      cookbook "nginx"
      not_if {json_cert.empty?}
      variables(:key => json_cert["#{service_name}_key"])
      action :create
    end

    Chef::Log.info("Nginx cookbook - Certs for service #{service_name} has been processed")
 rescue => e
   Chef::Log.error(e.message)
 end
end

action :add_s3 do #TODO: Create this resource in minio cookbook
  begin
    s3_port = new_resource.s3_port

    template "/etc/nginx/conf.d/s3.conf" do
      source "s3.conf.erb"
      owner user
      group user
      mode 0644
      cookbook "nginx"
      variables(:s3_port => s3_port)
      notifies :restart, "service[nginx]"
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :add_webui do #TODO: Create this resource in webui cookbook
  begin
    user = new_resource.user
    webui_port = new_resource.webui_port
    cdomain = new_resource.cdomain
    routes = local_routes()

    template "/etc/nginx/conf.d/webui.conf" do
      source "webui.conf.erb"
      owner user
      group user
      mode 0644
      cookbook "nginx"
      variables(:webui_port => webui_port, :cdomain => cdomain)
      notifies :restart, "service[nginx]"
    end

    template "/etc/nginx/conf.d/redirect.conf" do
      source "redirect.conf.erb"
      owner user
      group user
      mode 0644
      cookbook "nginx"
      variables(:routes => routes)
      notifies :restart, "service[nginx]"
    end
    Chef::Log.info("Nginx - Webui configuration has been processed successfully")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    service "nginx" do
      service_name "nginx"
      ignore_failure true
      supports :status => true, :enable => true
      action [:stop, :disable]
    end

    Chef::Log.info("Nginx cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    consul_servers = system('serf members -tag consul=ready | grep consul=ready &> /dev/null')
    if !node["nginx"]["registered"] and consul_servers
      query = {}
      query["ID"] = "nginx-#{node["hostname"]}"
      query["Name"] = "nginx"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 443
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         retries 3
         retry_delay 2
         action :nothing
      end.run_action(:run)

      node.set["nginx"]["registered"] = true
      Chef::Log.info("Nginx service has been registered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    consul_servers = system('serf members -tag consul=ready | grep consul=ready &> /dev/null')
    if node["nginx"]["registered"] and consul_servers
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/nginx-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["nginx"]["registered"] = false
      Chef::Log.info("Nginx service has been deregistered from consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
