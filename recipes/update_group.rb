#
# Update group permissions for hostgroup
#

cookbook_file '/usr/local/bin/groupupdate.py' do
  source "groupupdate.py"
  mode '0755'
  action :create
end

execute "Update guests group" do
  command "/usr/local/bin/groupupdate.py Guests chef-agent #{node['zabbix']['connection']['url']} #{node['zabbix']['connection']['user']} #{node['zabbix']['connection']['password']} 2> /tmp/screen.err | tee /tmp/screen.log"
end

