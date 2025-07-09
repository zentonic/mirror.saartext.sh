#!/bin/bash

space1="                   "
space2="                                    "

process() {
  if [[ "$page" == "help" ]]; then
    cat <<EOF

      saartext.sh

      TUI Browser für saartext.de
      
      ?,p       Hilfe
      q         Beenden
      [RETURN]  Startseite News 110
      
      Navigation:
      b,h,a     Eine Seite zurück
      n,l,d     Eine Seite vor

EOF
  else
    curl -s "https://www.saartext.de/$page" |
      sed -n '/<pre/,/<\/pre>/p' |
      sed s/"$space1\<pre class=\"saartext_page\"\>"/\<pre\>/ |
      sed s/"<\/pre>"// |
      sed s/"$space2"// |
      pandoc --from html --to markdown_strict
  fi
}

main() {
  local page="${1:-110}"
  while true; do
    process "$page"

    # Benutzereingabe abfragen
    read -p "[Q]uit hel[P]                     Seite: " input
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
