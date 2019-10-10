#!/bin/bash

export GIT_DIR=${GIT_DIR-`git rev-parse --git-common-dir`}
# Runs all executable hookname.d/* hooks and exits after,
# if any of them was not successful.
exitcodes=()
hookname="`basename $0`"
hookpath="`git config core.hooksPath`"

## For each hook  
for hook in $hookpath/$hookname.d/* "$GIT_DIR/hooks/$hookname"; do
	if [ -x "$hook" ]; then
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
	if [ $exitcode -ne 0 ]; then
		exit $exitcode
	fi
done

# If we get here then everything is hunky dorio and we need to exit with 0
exit 0
