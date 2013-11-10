#http_endpoint 8080
unix_service 'tomcat6'

log_file '/var/log/tomcat6/catalina.out', { :parser => 'log4j', :format => 'server_log' }
