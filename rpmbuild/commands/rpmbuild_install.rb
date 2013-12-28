param :machine
param 'domain'
param 'service_root', 'path to the folder where packages should be published at +domain+', 
  :default_value => '/var/www/html/packages/rpm' 

on_machine do |machine, params|
  machine.ssh 'rpmdev-setuptree'
  
  machine.mkdir params['service_root']
  machine.allow_apache_read_access('file_name' => params['service_root'])
  machine.ssh "createrepo #{params['service_root']}"
end