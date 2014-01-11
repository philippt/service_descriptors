description "asks jenkins (nicely) to execute a build for the specified jenkins job"

param! :jenkins_job
param "wait", "if 'true', will wait for the triggered build to be completed", :lookup_method => lambda { %w|true false| }, :default_value => "false"

execute do |params|
  $logger.info "triggering build for #{params["jenkins_job"]}"

  result = 0
    
  job_name = job_name_http("job_name" => params["jenkins_job"])
  
  last_build_so_far = nil
  
  @op.without_cache do
    builds = @op.list_builds_for_job(params["jenkins_job"]).sort do |b,a|
      a["number"] <=> b["number"]
    end
    if builds.size > 0
      last_build_so_far = builds.first
    end
  end
  
  $logger.info "last recorded build is ##{last_build_so_far["number"]}" unless last_build_so_far == nil
  
  p = {
    'machine' => 'localhost',
    'target_url' => "#{config_string('jenkins_url')}/job/#{job_name}/build",
    'data' => {
      'not' => 'relevant'
    }
  }
  auth = config_string('jenkins_auth', '')
  if auth != ''
    p['basic_auth'] = auth
  end
  @op.http_post(p)
  
  if params["wait"] == "true"
    sleep config_string('post_launch_wait_secs', "5").to_i
    
    @op.without_cache do
      new_builds = @op.list_builds_for_job(
        "jenkins_job" => params["jenkins_job"]
      )
      
      last_build_now = new_builds.sort do |b,a|
        a["number"] <=> b["number"]
      end.first
      
      if last_build_so_far != nil
        raise "did not find a build newer than ##{last_build_now}" unless (last_build_now["number"] > last_build_so_far["number"])
      end
      
      result = last_build_now["number"]
    end
  else
    if last_build_so_far && last_build_so_far.has_key?("number")
      # TODO a bit too approximate
      result = last_build_so_far["number"] + 1
    else
      result = 1
    end
  end
  
  result
end
