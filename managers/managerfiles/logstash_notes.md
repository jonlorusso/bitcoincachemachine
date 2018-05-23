
#input
  # tcp {
  #   port => 5514
  #   type => syslog
  #   #add_field => {"log_origin" => "btcbn_testnet"}
  # }


  # filter {
#   dns {
#     reverse => [ "source_host", "field_with_address" ]
#     resolve => [ "field_with_fqdn" ]
#     action => "replace"
#   }

#   if [type] == "syslog" {
#     grok {
#       match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
#       add_field => [ "received_at", "%{@timestamp}" ]
#       add_field => [ "received_from", "%{host}" ]
#     }
#     date {
#       match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
#     }
#   }
# }
#"%{log_origin}"