# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# if running zsh
if [ -n "$ZSH_VERSION" ]; then
    # include .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        . "$HOME/.zshrc"
    fi  
fi

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
# Go
export GOROOT=/opt/golang/1.5.1
export GOPATH=$HOME/Projects/.go
# Java
export _JAVA_OPTS="-Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true -Dsun.java2d.xrender=true"
export JAVA_HOME=/opt/jdk/x64/jdk1.7.0_79
export IDEA_JDK=/opt/jdk/tux
export M2_HOME=/opt/apache/maven/3.0.5

### PATH
export PATH=$PATH:$GOROOT/bin:$JAVA_HOME/bin:$M2_HOME/bin
