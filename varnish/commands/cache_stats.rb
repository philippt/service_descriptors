description 'returns the cache status for a varnish instance'

param :machine

on_machine do |machine, params|
  result = {}
  @op.varnish_stats(params).each do |stat|
    if stat["key"] == "cache_hit"
      result["hits"] = stat["value"]
    elsif stat["key"] == "cache_miss"
      result["misses"] = stat["value"]
    end
  end
  result
end
