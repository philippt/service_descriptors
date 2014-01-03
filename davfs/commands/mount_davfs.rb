param :machine

param! 'url'
param! 'path'
param! 'user'
param! 'password'

on_machine do |machine, params|
  secrets_file = machine.id['user'] == 'root' ? '/etc/davfs2/secrets' : "#{machine.home}/.davfs2/secrets"
  creds_line = "#{params['path']}\t#{params['user']}\t#{params['password']}"
  machine.append_to_file('file_name' => secrets_file, 'content' => creds_line)
  machine.ssh "mount -t davfs #{params['url']} #{params['path']}"   
end  
