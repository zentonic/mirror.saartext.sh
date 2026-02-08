#!/bin/bash

# set -e
# set -u
# set -x

process() {
  clear
  if [[ "$page" == "help" ]]; then
    echo -en "${C2}"
    cat <<EOF

      videotext.sh

      TUI Browser für Videotexte
      (bash und curl)
      
      ?,p       Hilfe
      q         Beenden
      [RETURN]  Startseite 
      
      Navigation:
      h a b -   Eine Seite zurück
      j s       Eine Unterseite runter
      k w       Eine Unterseite hoch
      l d n +   Eine Seite vor

      Aufruf:
      videotext --list    Provider auflisten
      videotext [PROVIDER] [PAGE] [SUBPAGE]
EOF
    echo -en "${R}"
  else
    echo -en "${C4}"
    bash $content_url $page $subpage
    echo -en "${R}"
  fi
}

main() {
  R="\e[0m"   # reset
  B="\e[1m"   # bold
  C1="\e[31m" # rot
  C2="\e[32m" # grün
  C3="\e[33m" # gelb
  C4="\e[34m" # blau
  C5="\e[35m" # lila
  C6="\e[36m" # hellblau

  SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
  command=$(basename "$0")
  if [[ $1 ]]; then
    command=$1
  fi

  while IFS= read -r line; do
    key=${line%% *}
    value=${line#* }
    if [[ $command == "videotext" || $command == "--list" ]]; then
      if [[ $key ]]; then
        if [[ $key == "#" ]]; then
          key=$value
          value=""
        fi
        if [[ $value ]]; then
          printf "%20s    %s\n" "$key" "$value"
        else
          printf "\n%s" "$key"
        fi
      fi
    elif [[ "$key" == "$command" ]]; then
      local config="$value"
      break
    fi
  done <$SCRIPT_DIR/Videotext_Providers.conf

  if [ -z "$config" ]; then
    echo "Provider nicht gefunden."
    echo "Liste mit --list"
    echo "Hilfe mit --help"
    exit 1
  fi

  provider=${config%" "*}
  startpage=${config##*" "}
  echo provider $provider
  echo startpage $startpage

  page="${2:-$startpage}"
  subpage="${3:-""}"
  echo page $page

  content_url=$SCRIPT_DIR/includes/$provider/get_content.sh

  while true; do
    process "$page" "$subpage" && [ -n "$1" ] # && exit 0

    echo -en "${C5}Q${C4}uit${R} "
    echo -en "${C4}hel${C5}P${R} "
    echo -en "     ${C6}$page${C5}/$subpage${C6}) "
    echo -en "${C4}←${B}${C5}h ${C4}↓${B}${C5}j${C6} ${B}${C5}k${C4}↑${R} ${B}${C5}l${C4}→${R}  "
    echo -en "${B}${C4}#${R}${C5}"
    read -n3 input
    echo -en "${R}"

    # Überprüfe die Eingabe
    case "$input" in
    "q" | "qqq" | "Q" | "QQQ") # Quit
      exit
      ;;
    "p" | "ppp" | "P" | "PPP" | "?" | "???") # Help
      page="help"
      subpage=1
      ;;
    "s" | "j" | "jjj" | "J") # subpage
      page=$(($page))
      subpage=$(($subpage + 1))
      ;;
    "S" | "k" | "kkk" | "K") # Up
      page=$(($page))
      subpage=$(($subpage - 1))
      ;;
    "n" | "nnn" | "lll" | "N" | "l" | "L" | "d" | "D") # Next
      page=$(($page + 1))
      subpage=1
      ;;
    "b" | "bbb" | "nnn" | "B" | "h" | "H" | "a" | "A") # Back
      page=$(($page - 1))
      subpage=1
      ;;
    *)
      if [[ "$input" =~ ^[0-9]+$ ]]; then
        page="$input"
        subpage=1
      else
        page=$startpage
        subpage=1
      fi
      ;;
    esac
  done
}

main "$@"
