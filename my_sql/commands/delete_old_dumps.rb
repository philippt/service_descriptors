description "deletes old dumps from the system (that is, all dumps except for newest X - this number can be configured)"

add_columns [ :name, :date, :host ]

param :machine
param "threshold", "the amount of dumps that should be left on the system (default: 5)"
        
on_machine do |machine, params|
  threshold = params.has_key?("threshold") ? params["threshold"].to_i : 5
  $logger.info("deleting all old dumps except for the #{threshold} newest ones...")

  # get a list of the dumps with the newest one first
  candidates = machine.list_dumps.sort { |x,y| y["date"] <=> x["date"] }

  # and delete the first x entries from the list (the entries we want to keep)
  1.upto(threshold) { |i| candidates.shift }

  # everything left on the list now shall be terminated
  morituri = candidates
  morituri.each do |moriturus|
    machine.delete_dump({
      "dump_name" => moriturus["name"]
    })
  end

  # and return the list of removed dumps
  $logger.info("successfully deleted #{morituri.size} dumps (their names are attached)")
  morituri
end
