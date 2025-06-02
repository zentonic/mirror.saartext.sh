#!/bin/bash

space1="                   " 
space2="                                    "

process() {
  curl -s "https://www.saartext.de/$page" | \
    sed -n '/<pre/,/<\/pre>/p' | \
    sed s/$space1\<pre class=\"saartext_page\"\>/\<pre\>/ | \
    sed s/"<\/pre>"// | \
    sed s/$space2// | \
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

