# Cookbook Name:: rackbox
# Recipe:: passenger
#
# Setup passenger apps
#

include_recipe "iptables"

iptables_rule "port_http"
iptables_rule "port_https"

include_recipe "nginx::ohai_plugin"

package "libcurl4-gnutls-dev"

nginx_url = node['nginx']['source']['url'] ||
  "http://nginx.org/download/nginx-#{node['nginx']['source']['version']}.tar.gz"

src_filepath = "#{Chef::Config['file_cache_path'] || '/tmp'}/nginx-#{node['nginx']['source']['version']}"


remote_file nginx_url do
  source nginx_url
  checksum node['nginx']['source']['checksum']
  path src_filepath + ".tar.gz"
  backup false
end

bash 'extract nginx src' do
  cwd ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath + ".tar.gz")} -C #{::File.dirname(src_filepath)}
  EOH
end

bash "Install passenger with nginx" do
  code "/opt/rbenv/shims/passenger-install-nginx-module --auto --prefix=/opt/nginx --nginx-source-dir=#{src_filepath} --extra-configure-flags='none'"
end

node.set['nginx']['daemon_disable'] = node['nginx']['upstart']['foreground']

template '/etc/init/nginx.conf' do
  source 'nginx-upstart.conf.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    :src_binary => node['nginx']['binary'],
    :pid => node['nginx']['pid'],
    :config => node['nginx']['source']['conf_path'],
    :foreground => node['nginx']['upstart']['foreground'],
    :respawn_limit => node['nginx']['upstart']['respawn_limit'],
    :runlevels => node['nginx']['upstart']['runlevels']
  )
end

service "nginx" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action :nothing
end
