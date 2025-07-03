#!/bin/bash
# -------------------------------
# saartext.sh
#
# TUI Client für saartext.de
#
# CC-BY-SA-4.0 holm / Christian Müller
# https://forgejo.mueller.network/holm/saartext.sh.git
#

process() {
  curl -s "https://www.saartext.de/$page" |
    sed -n '/<pre/,/<\/pre>/p' |
    sed s/"                    <pre class=\"saartext_page\">"/"<pre>"/ |
    sed s/"<\/pre>"// |
    sed s/"                                    "// |
    pandoc --from html --to markdown_strict
}

main() {
  local page="${1:-110}"
  while true; do
    process "$page"

    # Benutzereingabe abfragen
    read -p "Neue Seite eingeben (oder 'q' zum Beenden): " input
    echo

    # Überprüfe die Eingabe
    if [[ "$input" == "q" || "$input" == "Q" ]]; then
      echo "Programm wird beendet."
      break
    elif [[ "$input" =~ ^[0-9]+$ ]]; then
      page="$input"
    else
      page=110
    fi
  done
}

main "$@"
