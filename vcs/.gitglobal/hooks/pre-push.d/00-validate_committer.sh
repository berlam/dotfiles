#!/bin/bash

# An hook script to verify what is about to be pushed.  Called by "git
# push" after it has checked the remote status, but before anything has been
# pushed.  If this script exits with a non-zero status nothing will be pushed.
#
# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done
#
# If pushing without using a named remote those arguments will be equal.
#
# Information about the commits which are being pushed is supplied as lines to
# the standard input in the form:
#
#   <local ref> <local sha1> <remote ref> <remote sha1>
#
# This hook stops push, if one commit does not match the configured author.
remote="$1"
url="$2"

GIT_PATH="`which -a git | sed -n 2p`"
GIT_NAME=
GIT_EMAIL=

while read REMOTE; do
	PATTERN="`\"$GIT_PATH\" config --get \"user.$REMOTE.pattern\"`"
	if [ -z "$PATTERN" ]; then
		echo "Empty pattern for \"$REMOTE\""
		exit 1;
	fi
	if echo "$url" | egrep -q "$PATTERN"; then
		GIT_NAME="`\"$GIT_PATH\" config --get \"user.$REMOTE.name\"`"
		GIT_EMAIL="`\"$GIT_PATH\" config --get \"user.$REMOTE.email\"`"
		break
	fi
done < <("$GIT_PATH" config --name-only --get-regexp "^user\..+\.pattern$" | sed -r "s/^user\.(.+)\.pattern$/\1/")

#
# Fallback to global settings, if empty.
#
if [ -z "$GIT_NAME" ]; then
	GIT_NAME="`\"$GIT_PATH\" config --get --global user.name`"
fi
if [ -z "$GIT_EMAIL" ]; then
	GIT_EMAIL="`\"$GIT_PATH\" config --get --global user.email`"
fi

z40=0000000000000000000000000000000000000000

while read local_ref local_sha remote_ref remote_sha
do
	if [ "$local_sha" != $z40 ]; then
		if [ "$remote_sha" = $z40 ]; then
			# New branch, examine all commits
			range="$local_sha"
		else
			# Update to existing branch, examine new commits
			range="$remote_sha..$local_sha"
		fi

		# Check for correct author
		while read commit; do
			if [ -z "$GIT_PATH rev-list --author \"^$GIT_NAME <$GIT_EMAIL>$\" \"$commit\"" ]; then
				echo >&2 "Found commit with wrong author in $local_ref, not pushing"
				exit 1
			fi
		done < <("$GIT_PATH" rev-list --author "^$GIT_NAME" "$range")
	fi
done

exit 0
