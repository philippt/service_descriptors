param :machine

on_machine do |machine, params|
  target_dir = "#{machine.home}/tools/drush"
  machine.mkdir("dir_name" => target_dir, "recursive" => "true")
  machine.wget("target_dir" => target_dir, "url" => "http://ftp.drupal.org/files/projects/drush-7.x-4.5.tar.gz")
  machine.explode("tar_name" => "#{ŧarget_dir}/*.tar.gz", "working_dir" => target_dir)
    
  process_template(:profile, machine, "/etc/profile.d/drush.sh", binding())
end
