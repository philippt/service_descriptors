description 'lists all drupal modules found in the "modules" direcory of the specified drupal instance'

param :machine
param "drupal_home", "fully qualified path to the drupal installation", :mandatory => true

display_type :list

on_machine do |machine, params|
  machine.ssh("command" => "find #{params["drupal_home"]}/sites/all/modules -maxdepth 1 -type d").split("\n")
end