# shellcheck disable=SC2034
# FEEDS=(
#   # ["alias"]="http://example.com/rss.xml"
#   # "local /tmp/rss.xml"
#   # "local_atom /tmp/feed.xml"
# )

# Keeping my feeds private
# shellcheck disable=SC1090
source ~/.config/frdr/feeds.bash

FRDR_PAGER="w3m -T text/html"
FRDR_PREVIEWER="w3m -T text/html"
FRDR_SHOW_HELP=true

black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
grey=$(tput setaf 240)
lime_yellow=$(tput setaf 190)
powder_blue=$(tput setaf 153)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
bold=$(tput bold)
dim=$(tput dim)
normal=$(tput sgr0)
blink=$(tput blink)
reverse=$(tput smso)
underline=$(tput smul)

FRDR_POST_FMT=${cyan}${dim}"%(%d %b %y %k:%M)T${normal}  ${green}${bold}%12s${normal} ${cyan}${dim}│${normal} ${cyan}%s${normal}"
