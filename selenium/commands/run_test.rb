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
    content = machine.process_file("file_name" => test["file_name"], "bindings" => binding())
    machine.selenium_ruby('selenium' => content)
  else
    raise "unknown type #{test["type"]}"
  end
end
