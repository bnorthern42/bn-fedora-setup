#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

## First optimize DNF
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf
echo "fastestmirror=True" >> /etc/dnf/dnf.conf


## Basic setup
initpackages=(
	"gcc" "g++" "git" "curl" "wget" "lightdm" "awesome" "vim" "emacs"
)


for p in ${initpackages[@]};
do
	REQUIRED_PKG=$p
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	echo Checking for $REQUIRED_PKG: $PKG_OK
	if [ "" = "$PKG_OK" ]; then
	  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
	  sudo dnf --yes install $REQUIRED_PKG
	fi
done
## now a better shell
sudo dnf install zsh --yes
chsh -s $(which zsh)
sudo chsh -s $(which zsh)


#more fun
packages=(
	"konsole" "rufi" "librewolf"
	"highlight" "exa" "neofetch"
)


for p in ${packages[@]};
do
	REQUIRED_PKG=$p
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
	echo Checking for $REQUIRED_PKG: $PKG_OK
	if [ "" = "$PKG_OK" ]; then
	  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
	  sudo dnf --yes install $REQUIRED_PKG
	fi
done

## setup .zshrc (basic no seperate alias file
conf="$HOME/.zshrc"
sudo rm -f $conf

cat << EOF > $conf
source $HOME/.screenlayout/MainScreenLayout.sh
export ZSH="$HOME/.oh-my-zsh"
# theme
ZSH_THEME="amuse"
#plugins_basic
plugins(
	git
	colored-man-pages
	perms
	history
	aliases
)
source $ZSH/oh-my-zsh.sh
export PATH="~/bin:$PATH"
export PATH="$HOME/.emacs.d/bin:$PATH"

#simple aliases
alias ll='exa -lhga --color=always --group-directories-first --icons --octal-permissions --git --time-style=long-iso'
alias la='ls -A'
alias l='ls -CF'
alias llt='exa -lhg --color=always --group-directories-first --icons -T --git-ignore'
##adding color
alias ls='ls -hN --color=auto --group-directories-first'
## See open ##listening## ports
alias oplisten='netstat -tulpn | grep LISTEN' 


alias grep='grep --color=auto'
alias ccat='highlight --out-format=ansi'

alias emacs="emacsclient -c -a 'emacs'"



neofetch
EOF

##setup graphics for WM/DM
sudo systemctl enable lightdm
sudo systemctl set-default graphical.target




