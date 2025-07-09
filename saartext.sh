#!/bin/bash

process() {
  clear
  if [[ "$page" == "help" ]]; then
    cat <<EOF

      saartext.sh

      TUI Browser für saartext.de
      
      ?,p       Hilfe
      q         Beenden
      [RETURN]  Startseite News 110
      
      Navigation:
      b,h,a     - Eine Seite zurück
      n,l,d     + Eine Seite vor

EOF
  else
    curl -s "https://www.saartext.de/$page" |
      sed -e s/"saartext_page\">"/"\\n<SAARTEXT_START>"/ \
        -e s/"<\/pre>"/"<SAARTEXT_END>"/ |
      sed -nr '/SAARTEXT_START/,/SAARTEXT_END/p' |
      sed -e 's/<[^>]*>//g' |
      uniq
  fi
}

main() {
  local page="${1:-110}"
  while true; do
    process "$page" && [ -n "$1" ] && exit 0

    # Benutzereingabe abfragen
    read -p "[Q]uit hel[P] [b]$(($page - 1)) [n]$(($page + 1)) $page Page " input
    echo

    # Überprüfe die Eingabe
    case "$input" in
    q | Q) # Quit
      exit
      ;;
    p | P | "?") # Help
      page="help"
      ;;
    n | N | l | L | d | D) # Next
      page=$(($page + 1))
      ;;
    b | B | h | H | a | A) # Back
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
