# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.

# reminder (http://unix.stackexchange.com/a/46856/148427):
# 1. interactive login shell (profile)
#    - text console (tty)
#    - SSH
#    - "su -"
# 2. non-interactive login shell (profile)
#    - very rare
#    - X (with display manager)
# 3. interactive non-login shell (bashrc, zshrc)
#    - screen
#    - X terminal
#    - Emacs terminal buffer
#    - a shell inside another
# 4. non-interactive non-login shell
#    - shell runs a script
#    - command passed on its command line
umask 022

### Desktop
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_CTYPE="de_DE.UTF-8"
export LC_NUMERIC="de_DE.UTF-8"
export LC_TIME="de_DE.UTF-8"
export LC_COLLATE="C.UTF-8"
export LC_MONETARY="de_DE.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="de_DE.UTF-8"
export LC_NAME="de_DE.UTF-8"
export LC_ADDRESS="de_DE.UTF-8"
export LC_TELEPHONE="de_DE.UTF-8"
export LC_MEASUREMENT="de_DE.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"
export GNOME_DESKTOP_SESSION_ID=this-is-deprecated

### Programs
export EDITOR=vim
export BROWSER=google-chrome

export LESSHISTFILE=/dev/null

### Dev
export ANDROID_HOME=$HOME/android-sdk-linux
# Go
export GOROOT=/opt/golang/current
export GOPATH=$HOME/.golang:$HOME/Projects
export GOBIN=$HOME/.golang/bin
# Java
export _JAVA_OPTS="-Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true -Dsun.java2d.xrender=true"
export JAVA_HOME=/opt/jdk/x64/current
export M2_HOME=/opt/apache/maven/current
# JavaScript
export NODE_HOME=/opt/node/current

### PATH
export PATH=$PATH:$GOROOT/bin:$JAVA_HOME/bin:$M2_HOME/bin:$NODE_HOME/bin:$GOBIN
