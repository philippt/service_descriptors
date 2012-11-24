def rails(port = 3000)
  run_command "script/rails s -p #{port}"

  http_endpoint port
end
