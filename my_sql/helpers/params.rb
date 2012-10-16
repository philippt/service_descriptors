def param_database(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { |request|
      @op.with_machine(request.get_param_value('machine')) do |machine|
        machine.list_databases.map do |database|
          database["name"]
        end
      end
    },
    :autofill_context_key => 'database'
  })
  RHCP::CommandParam.new("database", "a database to work with", options)
end


def param_one_database(description="the database to work with",mandatory=true)
  RHCP::CommandParam.new("database", description,
    {
      :mandatory => mandatory,
      :lookup_method => lambda { |request|
        @op.with_machine(request.get_param_value('machine')) do |machine|
          machine.list_databases.map do |database|
            database["name"]
          end
        end
      }
    }
  )
end

def param_multiple_optional_databases(description, options={})
  merge_options_with_defaults(options, {
    :mandatory => false,
    :allows_multiple_values => true,
    :lookup_method => lambda { |request|
      @op.with_machine(request.get_param_value('machine')) do |machine|
        machine.list_databases.map do |database|
          database["name"]
        end
      end
    }
  })
  RHCP::CommandParam.new("database", description, options)
end
  
def param_dump(options = {})
  merge_options_with_defaults(options, {
    :mandatory => true,
    :lookup_method => lambda { |request|
      @op.with_machine(request.get_param_value("machine")) do |machine|
        machine.list_dumps.map do |dump|
          dump["name"]
        end
      end
    }            
  })
  RHCP::CommandParam.new("dump_name", "the dump with which we should work", options)
end
  
# def param_mysql_host(options = {})
  # merge_options_with_defaults(options, {
    # :mandatory => false,
    # :default_value => 'localhost'
  # })
  # RHCP::CommandParam.new("mysql_host", "a mysql host to work with", options)
# end