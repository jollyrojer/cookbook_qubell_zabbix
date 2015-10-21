#
# Installs and configure Zabbix agent
# based on https://github.com/laradji/zabbix cookbook
#

case node['platform_family'] 
  when 'windows'
    node.set['zabbix']['agent']['install_method']='chocolatey'
    
    powershell_script "disable_firewall" do
      flags "-ExecutionPolicy Unrestricted"
      code <<-EOH
        netsh advfirewall set allprofiles state off
      EOH
    end
    
    ruby_block  "set-env-programdata" do
      block do
        ENV["ProgramData"] = "C:\\ProgramData"
      end
    end

  when 'rhel', 'debian'
    node.set['zabbix']['agent']['install_method']='source'
    
    include_recipe "build-essential"
    include_recipe "yum-repoforge"

    service "iptables" do
      action :stop
    end
  end

include_recipe "zabbix"
