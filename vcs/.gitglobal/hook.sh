#!/bin/bash

# Runs all executable hookname.d/* hooks and exits after,
# if any of them was not successful.
exitcodes=()
hookname="`basename $0`"
hookpath="`git config core.hooksPath`"

# Fallback to default hooks location
if [ -z "$hookpath" ]; then
	hookpath="$GIT_DIR/hooks"
fi

## For each hook  
for hook in $hookpath/$hookname.d/*; do
	if test -x "$hook"; then
		$hook "$@"
		exitcode=$?
		exitcodes+=($exitcode)
	fi
done

# Now that we have run all of the hooks, we will now iterate over each of the statuses
# and if any of them are greater than 0 we will exit with that status
# echo $statusarray
for exitcode in ${exitcodes[@]}
do
	if test $exitcode -ne 0; then
		exit $exitcode
	fi
done

# If we get here then everything is hunky dorio and we need to exit with 0
exit 0
