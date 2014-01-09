user 'selenium'

canned_service 'rvm/rvm', { :ruby_version => "1.9.3", :user => @service['user'] }

run_command "xvfb-run java -jar selenium-server-standalone*.jar"

process_regex "selenium-server-standalone"

#listen_port 4444

log_file "log/selenium.log"

# see http://www.torkwrench.com/2011/12/16/d-bus-library-appears-to-be-incorrectly-set-up-failed-to-read-machine-uuid-failed-to-open-varlibdbusmachine-id/
post_installation do |machine, params|
  #machine.as_user('root') do |root|
  #  root.ssh "dbus-uuidgen > /var/lib/dbus/machine-id"
  #end
  machine.mkdir "#{machine.home}/tests"
end  
