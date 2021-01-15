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
export LC_DATE="de_DE.UTF-8"
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
### HiDPI
export QT_AUTO_SCREEN_SCALE_FACTOR=1
### VDPAU
export VDPAU_DRIVER=va_gl

### Programs
export EDITOR=nvim
export BROWSER=firefox

export LESSHISTFILE=/dev/null

### Dev
export GIT_COMPLETION_CHECKOUT_NO_GUESS=1
export ANDROID_HOME="$HOME/android-sdk-linux"
# Java
export _JAVA_OPTS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.xrender=true"
export JAVA_HOME=$(readlink -f `which javac` | sed "s:/bin/javac::")
export M2_HOME=$(readlink -f `which mvn` | sed "s:/bin/mvn::")
# Go
export GOROOT=/usr/lib/go
export GOBIN="$HOME/.golang/bin"
# Rust
export CARGO_HOME="$HOME/.cargo"
# JS
export NVM_DIR="$HOME/.nvm"
# dotNet
export DOTNET_CLI_TELEMETRY_OPTOUT=1

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

### PATH
# No whitespaces before ":"!
export PATH=$PATH\
:$JAVA_HOME/bin\
:$M2_HOME/bin\
:$ANDROID_HOME/tools\
:$ANDROID_HOME/platform-tools\
:$GOBIN\
:$CARGO_HOME/bin\
:$NPM_CONFIG_PREFIX/bin\
:/opt/google/appengine/go/current\
:$HOME/.local/share/JetBrains/Toolbox/apps\

if [ -z "$DISPLAY" -a $XDG_VTNR = 1 ]; then
	exec startx
fi

export PATH="$HOME/.cargo/bin:$PATH"
