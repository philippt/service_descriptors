tcp_endpoint [ 389 ]

unix_service "dirsrv"

log_file "/var/log/dirsrv/slapd-*/access", :format => 'access_log'
log_file "/var/log/dirsrv/slapd-*/errors", :format => 'server_log'
