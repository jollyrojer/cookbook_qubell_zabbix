def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
action :delete do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    get_host_request = {
      :method => 'host.get',
      :params => {
        :filter => {
          :host => new_resource.hostname
        }
      }
    }
    hosts = connection.query(get_host_request)
    
    if hosts.size == 0
      Chef::Log.info "Host #{new_resource.hostname} is not connected to Zabbix server"
    else
      Chef::Log.info "Going to delete #{new_resource.hostname}[#{hosts[0]["hostid"]}] host from Zabbix server"
      del_request = {
        :method => 'host.delete',
        :params => { 
          "hostid" => hosts[0]["hostid"]
        }
      }
      connection.query(del_request)
    end
      Chef::Log.info "Host #{new_resource.hostname} deleted from Zabbix server"
  end
end


