#
# Installs and configures Zabbix
# based on https://github.com/laradji/zabbix cookbook
#

directory node[:zabbix][:install_dir] do
  mode '0755'
end

service "iptables" do
  action :stop
end

execute "disable selinux" do
  command "setenforce 0"
end

case node['zabbix']['server']['install_method']
when "package"
  include_recipe "qubell-zabbix::server_package"
when "source"
  inclide_recipe "zabbix::server_source"
end

remote_file "#{node["qubell_zabbix"]["tmp_path"]}/zabbixapi.gem" do
  source node["qubell_zabbix"]["zabbixapi_gem_url"]
end

gem_package "zabbixapi" do
  source "#{node["qubell_zabbix"]["tmp_path"]}/zabbixapi.gem"
  version "2.4.5"
  action :install
end
