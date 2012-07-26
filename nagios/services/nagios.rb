#TODO asks_kindly_for_outgoing_tcp :all_destinations (probably only for virtualop.org like setups?)
#iptables -A FORWARD -s 10.60.10.35 -p tcp -m state --state NEW -j ACCEPT