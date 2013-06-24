unix_service "squid"

# TODO should be a local_tcp_endpoint
tcp_endpoint 3128

log_file "/var/log/squid/access.log", :parser => "squid"
