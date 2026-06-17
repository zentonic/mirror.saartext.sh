#!/bin/bash

# set -e
# set -u
# set -x

process() {
  clear
  if [[ "$page" == "help" ]]; then
    echo
    printf "  ${C3}╔══════════════════════════╗${R}\n"
    printf "  ${C3}║${R}  ${B}${C5}videotext.sh${R}            ${C3}║${R}\n"
    printf "  ${C3}║${R}  ${C6}TUI · bash & curl${R}       ${C3}║${R}\n"
    printf "  ${C3}╚══════════════════════════╝${R}\n"
    echo
    printf "  ${B}${C3}Navigation${R}\n"
    printf "  ${C3}──────────────────────────${R}\n"
    printf "  ${B}${C5}%-14s${R}%s\n" "h  a  b  -"  "Seite zurück"
    printf "  ${B}${C5}%-14s${R}%s\n" "l  d  n"     "Seite vor"
    printf "  ${B}${C5}%-14s${R}%s\n" "j  s"        "Unterseite ↓"
    printf "  ${B}${C5}%-14s${R}%s\n" "w  k"         "Unterseite ↑"
    printf "  ${B}${C5}%-14s${R}%s\n" "100 … 899"   "Seite direkt"
    echo
    printf "  ${B}${C3}Aktionen${R}\n"
    printf "  ${C3}──────────────────────────${R}\n"
    printf "  ${B}${C5}%-14s${R}%s\n" "?  p"        "Hilfe"
    printf "  ${B}${C5}%-14s${R}%s\n" "q"           "Beenden"
    printf "  ${B}${C5}%-14s${R}%s\n" "RETURN"      "Startseite"
    echo
  else
    bash $content_url $page $subpage
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

  if [[ $command == "--help" ]]; then
    echo "Aufruf: videotext [PROVIDER] [PAGE] [SUBPAGE]"
    echo "        videotext --list    Provider auflisten"
    echo "        videotext --help    Diese Hilfe"
    exit 0
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

  if [[ $command == "videotext" || $command == "--list" ]]; then
    exit 0
  fi

  if [ -z "$config" ]; then
    echo "Provider nicht gefunden."
    echo "Liste mit --list"
    echo "Hilfe mit --help"
    exit 1
  fi

  provider=${config%" "*}
  startpage=${config##*" "}

  page="${2:-$startpage}"
  subpage="${3:-""}"

  content_url=$SCRIPT_DIR/includes/$provider/get_content.sh

  while true; do
    process "$page" "$subpage" && [ -n "$1" ] # && exit 0

    echo -en "${C5}Q${C4}uit${R} "
    echo -en "${C4}hel${C5}P${R} "
    echo -en "     ${C6}$page${C5}/$subpage${C6}) "
    echo -en "${C4}←${B}${C5}h ${C4}↓${B}${C5}j${C6} ${B}${C5}k${C4}↑${R} ${B}${C5}l${C4}→${R}  "
    echo -en "${B}${C4}#${R}${C5}"
    read -n1 input
    if [[ "$input" =~ ^[0-9]$ ]]; then
      read -n2 rest
      input="$input$rest"
    fi
    echo -en "${R}"

    case "$input" in
    "q" | "Q") # Quit
      exit
      ;;
    "p" | "P" | "?") # Help
      page="help"
      subpage=1
      ;;
    "s" | "j" | "J") # Unterseite runter
      page=$(($page))
      subpage=$(($subpage + 1))
      ;;
    "w" | "W" | "S" | "k" | "K") # Unterseite hoch
      page=$(($page))
      subpage=$(($subpage - 1))
      ;;
    "n" | "l" | "L" | "d" | "D" | "N") # Vor
      page=$(($page + 1))
      subpage=1
      ;;
    "b" | "B" | "h" | "H" | "a" | "A" | "-") # Zurück
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
