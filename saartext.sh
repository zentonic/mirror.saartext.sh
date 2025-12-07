#!/bin/bash

# ==============================================================================
# Skriptname: saartext.sh
# Beschreibung: TUI Browser für saartext.de in BASH
# Autor: holm / Christian Müller - https://mueller.network
# Repo: https://forgejo.mueller.network/Zentonic/saartext.sh.git
# Lizenz: MIT-Lizenz (siehe Datei LICENSE)
#
# Copyright (c) 2025 holm / Christian Müller - https://mueller.network
# ==============================================================================

process() {
  clear
  if [[ "$page" == "help" ]]; then
    echo -en "${C2}"
    cat <<EOF

      saartext.sh

      TUI Browser für saartext.de
      
      ?,p       Hilfe
      q         Beenden
      [RETURN]  Startseite News 110
      
      Navigation:
      b,h,a,-   Eine Seite zurück
      n,l,d,+   Eine Seite vor

EOF
    echo -en "${R}"
  else
    echo -en "${C4}"
    curl -s "https://www.saartext.de/$page" |
      sed -e s/"saartext_page\">"/"\\n<SAARTEXT_START>"/ |
      sed -e s/"<\/pre>"/"<SAARTEXT_END>"/ |
      sed -nr '/SAARTEXT_START/,/SAARTEXT_END/p' |
      sed -e 's/<[^>]*>//g' |
      uniq
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

  local page="${1:-110}"
  while true; do
    process "$page" && [ -n "$1" ] && exit 0

    # Benutzereingabe abfragen
    # echo -e "0${BC1}1${BC2}2${C3}3${C4}4${C5}5${C6}6${R} "

    echo -en "${C4}Q${C5}uit${R} "
    echo -en "${C5}hel${C4}P${R} "
    echo -en "                   "
    echo -en "${B}${C1}-${C6}$page${B}${C2}+${R} "
    echo -en " ${B}${C6}#${R}${C2}"
    read -n3 input
    echo -en "${R}"

    # Überprüfe die Eingabe
    case "$input" in
    "q" | "qqq" | "Q" | "QQQ") # Quit
      exit
      ;;
    "p" | "ppp" | "P" | "PPP" | "?" | "???") # Help
      page="help"
      ;;
    "n" | "nnn" | "N" | "l" | "L" | "d" | "D") # Next
      page=$(($page + 1))
      ;;
    "b" | "bbb" | "B" | "h" | "H" | "a" | "A") # Back
      page=$(($page - 1))
      ;;
    *)
      if [[ "$input" =~ ^[0-9]+$ ]]; then
        page="$input"
      else
        page=110
      fi
      ;;
    esac
  done
}

main "$@"
