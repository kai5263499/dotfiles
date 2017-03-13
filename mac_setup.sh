#!/usr/bin/env bash

set +e

# Bootstrap Mac OS X specific configuration
# Tested in 10.10
# Author: Wes Widner

# sudo scutil --set HostName

function setup_settings {
	echo "managing sleep settings"
	sudo pmset -c sleep 0
	sudo pmset -c displaysleep 30

	sudo pmset -b sleep 5
	sudo pmset -b displaysleep 5

	sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
	defaults write com.apple.finder AppleShowAllFiles true
	defaults write -g AppleShowAllExtensions -bool true
	chflags nohidden ~/Library
	sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
	defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
	defaults write com.apple.finder EmptyTrashSecurely -bool true
	defaults write com.apple.dock autohide -bool true
	hash tmutil &> /dev/null && sudo tmutil disablelocal
	defaults write com.apple.dashboard mcx-disabled -boolean YES && killall Dock
}

function setup_brew {
	if hash brew 2>/dev/null; then
		echo "brew installed"
	else
		echo "install brew"
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	echo "installing brew cli apps"
	brew install \
	awscli \
	brew-pip \
	chrome-cli \
	curl \
	ffmpeg \
	git \
	git-flow \
	golang \
	jq \
	kubernetes-cli \
	mas \
	nmap \
	node \
	osquery \
	phantomjs \
	protobuf \
	python \
	rust \
	sbt \
	scala \
	ssh-copy-id \
	tmux \
	unrar \
	vim \
	wget \
	wireshark \
	youtube-dl \
	zeromq \
	zsh

	echo "installing brew cask apps"
	brew cask install \
	atom \
	audacity \
	calibre \
	charles \
	crashplan \
	cyberduck \
	debookee \
	docker \
	dropbox \
	eloquent \
	entropy \
	evernote \
	gogland-eap \
	google-chrome \
	google-cloud-sdk \
	grammarly \
	intellij-idea-ce \
	iterm2 \
	java7 \
	knockknock \
	kodi \
	launchrocket \
	makemkv \
	nvalt \
	pycharm-ce \
	simple-comic \
	skitch \
	sourcetree \
	steam \
	vagrant \
	virtualbox \
	viscosity \
	vlc \
	vlcstreamer
}

function setup_python {
	echo "installing python modules"
	pip install \
	boto3 \
	evernote \
	fabric \
	fabric-aws \
	pyrasite \
	scapy
}

function setup_zsh {
	if [ -d ~/.oh-my-zsh ]; then
		rm -rf ~/.oh-my-zsh
	fi
	# if hash zsh 2>/dev/null; then
	# 	echo "zsh installed"
	# else
	# 	echo "installing oh my zsh"
	export DISABLE_UPDATE_PROMPT=true

	wget --no-check-certificate http://install.ohmyz.sh -O - | sh
	# fi

	cat > ~/.zshrc<<EOL
export ZSH=$HOME/.oh-my-zsh

HISTSIZE=10000000
SAVEHIST=10000000

ZSH_THEME="fino"

plugins=(git, osx, brew, docker, git-flow, git-extras, pip, sbt, scala, tmux, atom)

source $ZSH/oh-my-zsh.sh

export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$HOME/.rvm/bin"

export EDITOR='vim'

export VM_MEMORY=4096

export JAVA_HOME="$(/usr/libexec/java_home)"

alias chrome="open ~/Applications/Google\ Chrome.app/ --args --disable-web-security"

export DEFAULT_USER=$(whoami)@$(hostname)

source $HOME/.cargo/env

if [ -f $HOME/.api_creds ]; then
	source $HOME/.api_creds
fi
EOL

	source ~/.zshrc
}

function setup_vim {
	echo "setting up vim"
	rm -rf ~/.vim
	mkdir -p ~/.vim/bundle
	mkdir -p ~/.vim/colors

	git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	git clone https://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized
	cp -R ~/.vim/bundle/vim-colors-solarized/colors/solarized.vim ~/.vim/colors

	cat >~/.vmrc <<EOL
set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-fugitive'
Bundle 'scrooloose/syntastic'
Bundle 'jisaacks/GitGutter'
Bundle 'tpope/vim-surround'
Bundle 'scrooloose/nerdtree'
Bundle 'kien/ctrlp.vim'
Bundle 'bling/vim-airline'
Bundle 'pangloss/vim-javascript'
Bundle 'slim-template/vim-slim'
Bundle 'Lokaltog/vim-powerline'

call vundle#end()
filetype plugin indent on

syntax enable
let g:solarized_termtrans = 1
let g:solarized_visibility = "high"
let g:solarized_contrast = "high"
set background=dark
colorscheme solarized

set noswapfile
set nobackup
set tabstop=2
set nowrap
set number
set expandtab

set t_Co=256                        " force vim to use 256 colors
let g:solarized_termcolors=256      " use solarized 256 fallback
EOL

	vim +PluginInstall +qall
}

function setup_tmux {
	echo "setting up tmux"

	cat >~/.tmux.conf <<EOL
############################################################################
# Reset Prefix
############################################################################
set -g prefix C-a
bind-key a send-prefix # for nested tmux sessions
bind-key C-a send-prefix

############################################################################
# Global options
############################################################################
# large history
set-option -g history-limit 10000

# Automatically set window title
setw -g automatic-rename

# Titles (window number, program name, active (or not)
set-option -g set-titles on
set-option -g set-titles-string '#H:#S.#I.#P #W #T'

# Start windows and panes at 1
set -g base-index 1
setw -g pane-base-index 1

set -g status-interval 60

set -g default-terminal "screen-256color"

############################################################################
# Unbindings
############################################################################
unbind C-b # unbind default leader key

############################################################################
# Bindings
############################################################################
# reload tmux conf
bind-key r source-file ~/.tmux.conf

bind | split-window -h
bind - split-window -v

# send C-a to terminal to let me move to the beginning of the line
bind a send-prefix

############################################################################
# COLOUR (Solarized dark)
# from https://github.com/seebi/tmux-colors-solarized
############################################################################
# default statusbar colors
set-option -g status-bg colour235 #base02
set-option -g status-fg colour130 #yellow
set-option -g status-attr default

# default window title colors
set-window-option -g window-status-fg colour33 #base0
set-window-option -g window-status-bg default
#set-window-option -g window-status-attr dim

# active window title colors
set-window-option -g window-status-current-fg colour196 #orange
set-window-option -g window-status-current-bg default
#set-window-option -g window-status-current-attr bright

# pane border
set-option -g pane-border-fg colour235 #base02
set-option -g pane-active-border-fg colour46 #base01

# message text
set-option -g message-bg colour235 #base02
set-option -g message-fg colour196 #orange

# pane number display
set-option -g display-panes-active-colour colour20 #blue
set-option -g display-panes-colour colour196 #orange

# clock
set-window-option -g clock-mode-colour colour40 #green
EOL

}

function setup_sua {
	echo "setting up sua utility"
	cat >/usr/local/bin/sua<<EOL
#!/bin/bash

set -x

BACKUP_ORIGIONAL=false

while getopts "b?" opt; do
    case "$opt" in
    b|\?)
        BACKUP_ORIGIONAL=true
        ;;
    esac
done

ffmpeg -i "$1" -filter:a "atempo=2.0" -c:a libmp3lame -q:a 4 tmp.mp3

if [[ $BACKUP_ORIGIONAL == true ]]; then
	mv "$1" "${1}-slow"
fi

mv tmp.mp3 "$1"
EOL
	chmod +x /usr/local/bin/sua
}

function setup_mas {
	if [[ -n "APPLE_ID" && -n "APPLE_PASSWORD" ]]
	then
		mas signin $APPLE_ID $APPLE_PASSWORD

		echo "installing App Store apps"
		mas install 497799835 # Xcode
		mas install 926036361 # LastPass
		mas install 403388562 # Transmit
		mas install 883878097 # servers
		mas install 412814284 # Mobile mouse servers
		mas install 473532262 # Text2speech PRO
		mas install 715768417 # Microsoft Remote Desktop
	fi
}

echo "Starting installation"
setup_settings
setup_brew
setup_python
setup_zsh
setup_vim
setup_tmux
setup_sua
setup_mas
