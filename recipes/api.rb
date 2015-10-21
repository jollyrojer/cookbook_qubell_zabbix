zabbix_api_call "run api-call" do
  server_connection node[:zabbix][:server_connection]
  method node[:zabbix][:method]
  parameters node[:zabbix][:parameters]
end
