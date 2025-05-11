#!/bin/bash

page=$1

if [ -z "$1" ]
  then
    page=110
fi

curl -s "https://www.saartext.de/$page" | sed -n '/<pre/,/<\/pre>/p' | sed s/"                    <pre class=\"saartext_page\">"/"<pre>"/ | sed s/"<\/pre>"// | sed s/"                                    "// | pandoc --from html --to markdown_strict
