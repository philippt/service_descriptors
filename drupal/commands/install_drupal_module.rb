description 'downloads and installs a drupal module into the selected drupal instance'

param :machine
param "drupal_home", "fully qualified path to the drupal installation", :mandatory => true
param "module_url", "the http url from which to download the module", :mandatory => true

on_machine do |machine, params|
  module_dir = params["drupal_home"] + '/sites/all/modules'
  
  machine.wget("url" => params["module_url"], "target_dir" => module_dir)
  
  machine.untar(
    "working_dir" => module_dir, 
    "tar_name" => module_dir + '/' + params["module_url"].split('/').last
  )
end