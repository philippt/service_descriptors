param :machine

param! "test_name", "might include slashes"
param! "content", "(might also include slashes)"

on_machine do |machine, params|
  machine.write_file("target_filename" => "tests/#{params["test_name"]}", "content" => params["content"])
  
  @op.cache_bomb
  machine.list_selenium_tests
end
