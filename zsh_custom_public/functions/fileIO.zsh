##
# Extract various archive formats with a single command.
# Usage: ex <file>
# Supported formats: .tar.bz2, .tar.gz, .bz2, .rar, .gz, .tar, .tbz2,
#                    .tgz, .zip, .Z, .7z, .deb, .tar.xz, .tar.zst
##
ex ()
{
        if [ -f "$1" ] ; then
                case $1 in
                        *.tar.bz2) tar xjf $1   ;;
                        *.tar.gz)  tar xzf $1   ;;
                        *.bz2)     bunzip2 $1   ;;
                        *.rar)     unrar x $1   ;;
                        *.gz)      gunzip  $1   ;;
                        *.tar)     tar xf  $1   ;;
                        *.tbz2)    tar xjf $1   ;;
                        *.tgz)     tar xzf $1   ;;
                        *.zip)     unzip   $1 -d "unzipped-$1"	;;
                        *.Z)       uncompress $1		;;
                        *.7z)      7z x $1              	;;
                        *.deb)     ar x $1              ;;
                        *.tar.xz)  tar xf $1    ;;
                        *.tar.zst) unzstd $1    ;;
                        *)                 echo "'$1' cannot be extracted with ex command"
                esac
        else
                echo "'$1' is not a valid file or \$1 is missing"
        fi
        }

##
# Create a new directory and immediately change into it.
# Usage: mcd <directory_name>
##
mcd () {
    mkdir -p $1
    cd $1
}

##
# Copy stdin to the system clipboard using xclip.
# Usage: echo "text" | _copy
##
configd() {
  pushd ~/.config/$1
}