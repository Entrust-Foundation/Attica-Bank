# Copyright (C) 2008 Richard Hughes <richard@hughsie.com>
#
# Licensed under the GNU General Public License Version 2
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

command_not_found_handle () {
	local runcnf=1
	local retval=127

	# only search for the command if we're interactive
	[[ $- == *"i"* ]] || runcnf=0

	# don't run if DBus isn't running
	[[ ! -S /run/dbus/system_bus_socket ]] && runcnf=0

	# don't run if packagekitd doesn't exist in the _system_ root
	[[ ! -x '/usr/lib/packagekitd' ]] && runcnf=0

	# don't run if bash command completion is being run
	[[ -n ${COMP_CWORD-} ]] && runcnf=0
	
	# don't run if we've been uninstalled since the shell was launched
	[[ ! -x '/usr/lib/pk-command-not-found' ]] && runcnf=0

	# run the command, or just print a warning
	if [ $runcnf -eq 1 ]; then
		'/usr/lib/pk-command-not-found' "$@"
		retval=$?
	elif [[ -n "${BASH_VERSION-}" ]]; then
		printf >&2 'bash: %scommand not found\n' "${1:+$1: }"
	fi

	# return success or failure
	return $retval
}

if [[ -n "${ZSH_VERSION-}" ]]; then
	command_not_found_handler () {
		command_not_found_handle "$@"
	}
fi
