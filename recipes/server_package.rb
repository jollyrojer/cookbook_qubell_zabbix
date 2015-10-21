# Author:: Anton Butovich (<abutovich@qubell.com>)
# Cookbook Name:: zabbix
# Recipe:: server_package
#
# Copyright 2015, Qubell
#
# Apache 2.0
#

case node['platform_family']
when "rhel"
  yum_repository 'zabbix' do
    description "Zabbix Official Repository"
    baseurl "http://repo.zabbix.com/zabbix/#{node['zabbix']['server']['version']}/rhel/6/$basearch/"
    gpgkey 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
    enabled true
    action :create
  end
  yum_repository 'zabbix-utils' do
    description "Zabbix Official unsupported Repository"
    baseurl "http://repo.zabbix.com/non-supported/rhel/6/$basearch/"
    gpgkey 'http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX'
    enabled true
    action :create
  end

  # install packages depending on 
  packages = ["zabbix-server-#{node['zabbix']['database']['install_method']}","zabbix-web-#{node['zabbix']['database']['install_method']}"]
  packages.each do |pck|
   package pck do
     action :install
   end
  end
end

# Create root folders
root_dirs = [
  node['zabbix']['external_dir'],
  node['zabbix']['server']['include_dir'],
  node['zabbix']['alert_dir'],
  node['zabbix']['web_dir']
]

root_dirs.each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '755'
    recursive true
  end
end

# install zabbix server conf
template "#{node['zabbix']['etc_dir']}/zabbix_server.conf" do
  cookbook 'zabbix'
  source 'zabbix_server.conf.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    :dbhost             => node['zabbix']['database']['dbhost'],
    :dbname             => node['zabbix']['database']['dbname'],
    :dbuser             => node['zabbix']['database']['dbuser'],
    :dbpassword         => node['zabbix']['database']['dbpassword'],
    :dbport             => node['zabbix']['database']['dbport'],
    :java_gateway       => node['zabbix']['server']['java_gateway'],
    :java_gateway_port  => node['zabbix']['server']['java_gateway_port'],
    :java_pollers       => node['zabbix']['server']['java_pollers']
  )
  notifies :restart, 'service[zabbix-server]', :delayed
end

# Define zabbix-server service
service 'zabbix-server' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:start, :enable]
end

# set timezone to php
execute "set timezone" do
  command "echo \"date.timezone = #{node["qubell_zabbix"]["timezone"]}\" >> /etc/php.ini"
end

# install zabbix PHP config file
template "#{node['zabbix']['web_dir']}/zabbix.conf.php" do
  cookbook 'zabbix'
  source 'zabbix_web.conf.php.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(
    :database => node['zabbix']['database'],
    :server => node['zabbix']['server']
  )
  notifies :restart, 'service[httpd]', :delayed
end

# Define httpd service
service 'httpd' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action [:start, :enable]
end
