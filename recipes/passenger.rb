# Cookbook Name:: rackbox
# Recipe:: passenger
#
# Setup passenger apps
#

include_recipe "iptables"

iptables_rule "port_http"
iptables_rule "port_https"

include_recipe "rbenv::ohai_plugin"

node.override["nginx"]["passenger"]["gem_binary"] = node['languages']['ruby']['gem_bin']

include_recipe "nginx::source"

#package "libcurl4-openssl-dev"

#Array(node["rackbox"]["apps"]).each_with_index do |app, index|

  #app_dir      = ::File.join(node["appbox"]["apps_dir"], app["appname"], 'current')

  #config = node["rackbox"]["default_config"]["nginx"]

  #template( File.join(node["nginx"]["dir"], "sites-available", app["appname"]) ) do
    #source    config["template_name"]
    #cookbook  config["template_cookbook"]
    #mode      "0644"
    #owner     "root"
    #group     "root"
    #variables(
      #:root_path   => ::File.join(app_dir, 'public'),
      #:log_dir     => node["nginx"]["log_dir"],
      #:appname     => app["appname"],
      #:hostname    => app["hostname"],
      #:listen_port => config["listen_port"],
      #:ssl_key     => config["ssl_key"],
      #:ssl_cert    => config["ssl_cert"]
    #)
    #notifies :reload, "service[nginx]"
  #end

#end
