#
# This recipe allow managing zabbix hosts
#
case node["qubell-zabbix"]["host_action"]
  when "create"
    Array(node[:zabbix][:agent][:hostname]).each do | h|
      interface = { :type => 1, :main => 1, :useip => 1, :ip => "", :dns => "", :port => node[:zabbix][:agent][:listen_port]  }
      case h 
        when /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
          interface[:ip] = h
        else
          interface[:useip] = 0
          interface[:dns] = h
      end
  
      case node.platform_family
        when "rhel"
          templates = ["Template OS Linux"]
        when "windows"
          templates = ["Template OS Windows"]
        else
          templates = []
      end

      zabbix_host h do
        action :create_or_update
        create_missing_groups true
        server_connection node[:zabbix][:connection]
        parameters ({
          :host => h,
          :groupNames => node[:zabbix][:agent][:groups],
          :templates => templates | node[:zabbix][:agent][:templates],
          :interfaces => [interface]
        })
      end
    end

  when "delete"
    Array(node[:zabbix][:agent][:hostname]).each do |host|
      qubell_zabbix_delete_host host do
      server_connection node[:zabbix][:connection]
        action :delete
      end
    end
end
