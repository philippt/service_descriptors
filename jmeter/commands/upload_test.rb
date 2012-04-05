description "uploads a test from the vop machine to the target machine"

param :machine
param! "test", "the test that should be uploaded", :lookup_method => lambda { |request|
  @op.list_tests("machine" => "localhost")
}

on_machine do |machine, params|
  @op.with_machine("localhost") do |localhost|
    machine.upload_file(
      "local_file" => localhost.home + "/tests/" + params["test"] + ".jmx",
      "target_file" => machine.home + "/tests/"
    )
  end
end
