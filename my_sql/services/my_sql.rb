runlevel "infrastructure"

# TODO actually, that depends on the distribution
#puts machine.name
names = {
  "centos" => "mysqld",
  "ubuntu" => "mysql"
}
unix_service names
