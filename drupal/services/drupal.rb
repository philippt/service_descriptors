#static_html

#config_template :settings_conf, "#{params["service_root"]}/sites/default/settings.php"

#custom_nagios_check :check_http_host
#nagios_service "HTTP", "check_http_host!#{params["domain"]}"

# TODO hardcoded database name
#database "drupal"
#backup :local_files => "#{params["service_root"]}/sites/default/files"