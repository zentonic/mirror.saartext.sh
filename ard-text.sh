#!/bin/bash

process() {
  clear
  if [[ "$page" == "help" ]]; then
    echo -en "${C2}"
    cat <<EOF

      ard-text.sh

      TUI Browser für ard-text.de
      
      ?,p       Hilfe
      q         Beenden
      [RETURN]  Startseite 100
      
      Navigation:
      h b a -   Eine Seite zurück
      j s       Eine Unterseite runter
      k w       Eine Unterseite hoch
      l n d +   Eine Seite vor

EOF
    echo -en "${R}"
  else
    echo -en "${C4}"
    curl -s "https://www.ard-text.de/index.php?page=$page\&sub=$sub" |
      sed -e s/"<div id='page_"/"\\n<ARDTEXT_START><div id='page_"/ |
      sed -e s/"ctc_test\">"/"<ARDTEXT_END>"/ |
      sed -nr '/ARDTEXT_START/,/ARDTEXT_END/p' |
      sed -e 's/&nbsp;/ /g' |
      sed -e 's/&auml;/ä/g' |
      sed -e 's/&ouml;/ö/g' |
      sed -e 's/&uuml;/ü/g' |
      sed -e 's/&Auml;/Ä/g' |
      sed -e 's/&Ouml;/Ö/g' |
      sed -e 's/&Uuml;/Ü/g' |
      sed -e 's/&szlig;/ß/g' |
      sed -e 's/&lt;/-/g' |
      sed -e 's/&gt;/-/g' |
      sed -e s%"<img src='./img/g[0-9a-z]*.gif'>"%·%g |
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

  local page="${1:-100}"
  local sub=1
  while true; do
    process "$page" && [ -n "$1" ] && exit 0

    # Benutzereingabe abfragen
    # echo -e "0${BC1}1${BC2}2${C3}3${C4}4${C5}5${C6}6${R} "

    echo -en "${C5}Q${C4}uit${R} "
    echo -en "${C4}hel${C5}P${R} "
    echo -en "   ${C6}$page (/$sub) "
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
      sub=1
      ;;
    "s" | "j" | "jjj" | "J") # Sub
      page=$(($page))
      sub=$(($sub + 1))
      ;;
    "S" | "k" | "kkk" | "K") # Up
      page=$(($page))
      sub=$(($sub - 1))
      ;;
    "n" | "nnn" | "lll" | "N" | "l" | "L" | "d" | "D") # Next
      page=$(($page + 1))
      sub=1
      ;;
    "b" | "bbb" | "nnn" | "B" | "h" | "H" | "a" | "A") # Back
      page=$(($page - 1))
      sub=1
      ;;
    *)
      if [[ "$input" =~ ^[0-9]+$ ]]; then
        page="$input"
        sub=1
      else
        page=100
        sub=1
      fi
      ;;
    esac
  done
}

main "$@"
