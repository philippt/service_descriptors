param :machine

on_machine do |machine, params|
  while (true)
    @op.without_cache do
      stats = machine.cache_stats
      puts "(hits/misses) #{stats["hits"]} / #{stats["misses"]}"
    end
    sleep 5
  end
end
