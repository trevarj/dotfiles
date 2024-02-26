#!/bin/awk
## Parses XDG desktop files and outputs them if they:
## 1. Have an Exec field
## 2. Are not NoDisplay=true
## 3. Are not Hidden=true
BEGIN {
	ORS = "\000"
	FS = "="
	OFS = "/"
	PROCINFO["sorted_in"] = "@ind_str_asc"
}

FNR == 1 {
	if (! show) {
		hidden[name] = fname
	}
	if (show && ! (name in hidden) && exec) {
		entries[name] = fname
	}
	entry = 0
	exec = 0
	show = 1
	name = ""
	fname = FILENAME
}

$0 == "[Desktop Entry]" {
	entry = 1
	next
}

entry && index($0, "[") == 1 {
	entry = 0
	next
}

entry && $1 == "Name" {
	name = substr($0, length($1) + 2)
}

entry && $1 == "Exec" {
	exec = 1
}

entry && $1 == "NoDisplay" && $2 == "true" {
	show = 0
}

entry && $1 == "Hidden" && $2 == "true" {
	show = 0
}

END {
	for (e in entries) {
		print entries[e], e
	}
}

