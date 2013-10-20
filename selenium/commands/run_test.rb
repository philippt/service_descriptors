param :machine
param! "test_name", "name of the test that should be executed"

accept_extra_params

on_machine do |machine, params|
  if params.has_key? 'extra_params'
    params['extra_params'].each do |k,v|
      values = v.is_a?(Array) ? v : [ v ]
      values.each do |value|
        params[k] = value
      end
    end
    #params.merge! params['extra_params']
  end 
  
  test = machine.list_selenium_tests.select { |x| x["name"] == params["test_name"] }.first
  
  if test["type"] == "rb"
    work_dir = machine.home + "/generated"
    tmp_file = work_dir + '/' + params["test_name"]
    
    content = machine.process_file("file_name" => test["file_name"], "bindings" => binding())
    
    #content = machine.read_file(test["file_name"])
    process_local_template(:selenium_ruby, machine, tmp_file, binding())
    
    machine.rvm_ssh "ruby #{tmp_file}"
  else
    raise "unknown type #{test["type"]}"
  end
end
