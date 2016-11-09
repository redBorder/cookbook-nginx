
# Cookbook Name:: nginx
#
# Provider:: config
#

include Nginx::Helper

action :add do
  begin

    user = new_resource.user
    webui_port = new_resource.webui_port
    routes = local_routes()

    yum_package "nginx" do
      action :upgrade
      flush_cache [:before]
    end

    user user do
      action :create
      system true
    end

    %w[ /var/www /var/www/cache /var/log/nginx ].each do |path|
      directory path do
        owner user
        group user
        mode 0755
        action :create
      end
    end

    template "/etc/nginx/nginx.conf" do
      source "nginx.conf.erb"
      owner user
      group user
      mode 0644
      cookbook nginx
      variable(:user => user)
      notifies :restart, "service[nginx]"
    end

    template "/etc/nginx/conf.d/webui.conf" do
      source "webui.conf.erb"
      owner user
      group user
      mode 0644
      cookbook nginx
      variable(:webui_port => webui_port)
      notifies :restart, "service[nginx]"
    end

    template "/etc/nginx/conf.d/redirect.conf" do
      source "redirect.conf.erb"
      owner user
      group user
      mode 0644
      cookbook nginx
      variable(:routes => routes)
      notifies :restart, "service[nginx]"
    end

    service "nginx" do
      service_name "nginx"
      ignore_failure true
      supports :status => true, :reload => true, :restart => true, :enable => true
      action [:start, :enable]
    end 

     Chef::Log.info("nginx has been configured correctly")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
     # ... your code here ...
     Chef::Log.info("nginx has been deleted correctly")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    if !node["nginx"]["registered"]
      query = {}
      query["ID"] = "nginx-#{node["hostname"]}"
      query["Name"] = "nginx"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 443
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.set["nginx"]["registered"] = true
    end

    Chef::Log.info("Nginx service has been registered to consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["nginx"]["registered"]
      execute 'Deregister service in consul' do
        command "curl http://localhost:8500/v1/agent/service/deregister/nginx-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.set["nginx"]["registered"] = false
    end

    Chef::Log.info("Nginx service has been deregistered from consul")
  rescue => e
    Chef::Log.error(e.message)
  end
end
