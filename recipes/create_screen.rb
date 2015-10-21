#
# Create screen for host
#

cookbook_file '/usr/local/bin/screen.py' do
  source "screen.py"
  mode '0755'
  action :create
end

node.set['zabbix']['agent']['screenid'] = []

Array(node['zabbix']['agent']['hostname']).each do | h |
  ruby_block "create screen #{h}" do
    block do
      Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)
      command = "/usr/local/bin/screen.py #{h} #{h} #{node['zabbix']['connection']['url']} #{node['zabbix']['connection']['user']} #{node['zabbix']['connection']['password']} 2> /tmp/screen.err | tee /tmp/screen.log"
      command_out = shell_out(command)
      node.set['zabbix']['agent']['screenid'] = node.zabbix.agent.screenid | [ command_out.stdout ]
    end
    action :create
  end
end
