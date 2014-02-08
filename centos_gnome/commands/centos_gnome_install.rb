param :machine

on_machine do |machine, params|
  machine.as_root do |root|
    root.ssh('yum groupinstall -y "Desktop" "X Window System"')
  end
end
