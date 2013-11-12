param :machine
param! 'selenium', 'ruby selenium code', :allows_multiple_values => true

accept_extra_params

on_machine do |m, params|
  m.as_user('selenium') do |machine|
    if params.has_key? 'extra_params'
      params['extra_params'].each do |k,v|
        values = v.is_a?(Array) ? v : [ v ]
        values.each do |value|
          params[k] = value
        end
      end
      #params.merge! params['extra_params']
    end
    
    work_dir = machine.home + "/generated"
    tmp_file = work_dir + '/selenium_ruby_' + Time.now().to_i.to_s + '.rb'
    
    content = params['selenium'].join("\n")
    process_local_template(:selenium_ruby, machine, tmp_file, binding())
    machine.rvm_ssh "ruby #{tmp_file}"  
  end
end
