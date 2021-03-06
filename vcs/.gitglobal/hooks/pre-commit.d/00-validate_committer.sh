#!/bin/bash
#
# An hook script to change the author to the configured value.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#
# To enable this hook, rename this file to "pre-commit".

# Usage in .gitconfig:
# [user "$REMOTE_ID"]
# 	pattern = A regex pattern, e.g. "github\.com".
# 	name = The name to use. Empty means "use global".
# 	email = The email to use. Empty means "use global".

GIT_PATH="`which -a git | sed -n 2p`"
GIT_NAME=
GIT_EMAIL=

#
# Find settings for remote.
#
while read REMOTE; do
	PATTERN="`\"$GIT_PATH\" config \"user.$REMOTE.pattern\"`"
	if [ -z "$PATTERN" ]; then
		echo "Empty pattern for \"$REMOTE\""
		exit 1;
	fi
	if "$GIT_PATH" remote get-url --push origin | egrep -q "$PATTERN"; then
		GIT_NAME="`\"$GIT_PATH\" config \"user.$REMOTE.name\"`"
		GIT_EMAIL="`\"$GIT_PATH\" config \"user.$REMOTE.email\"`"
		break
	fi
done < <("$GIT_PATH" config --name-only --get-regexp "^user\..+\.pattern$" | sed -r "s/^user\.(.+)\.pattern$/\1/")
#
# Fallback to global settings, if empty.
#
if [ -z "$GIT_NAME" ]; then
	GIT_NAME="`\"$GIT_PATH\" config --global user.name`"
fi
if [ -z "$GIT_EMAIL" ]; then
	GIT_EMAIL="`\"$GIT_PATH\" config --global user.email`"
fi
#
# Set values, if not empty and different to previous.
#
PRE_COMMIT_USER_CHANGE=false
if [ -n "$GIT_NAME" ] && [ "$GIT_NAME" != "`\"$GIT_PATH\" config user.name`" ]; then
	"$GIT_PATH" config --local --replace-all user.name "$GIT_NAME"
	echo "Setting user.name to \"$GIT_NAME\""
	PRE_COMMIT_USER_CHANGE=true
fi
if [ -n "$GIT_EMAIL" ] && [ "$GIT_EMAIL" != "`\"$GIT_PATH\" config user.email`" ]; then
	"$GIT_PATH" config --local --replace-all user.email "$GIT_EMAIL"
	echo "Setting user.email to \"$GIT_EMAIL\""
	PRE_COMMIT_USER_CHANGE=true
fi
if [ "$PRE_COMMIT_USER_CHANGE" = true ]; then
	echo "Please retry commit!"
	exit 1
fi

echo "Commit as \"$GIT_NAME ($GIT_EMAIL)\""

exit 0
