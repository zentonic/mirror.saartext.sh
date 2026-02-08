#!/bin/bash

page=$1

if [ -n "$2" ]; then
  subpage=$(printf "%02d" $2)
  page=$page/$subpage
fi

curl -s "https://www.saartext.de/$page" |
  sed -e s/"saartext_page\">"/"\\n<SAARTEXT_START>"/ |
  sed -e s/"<\/pre>"/"<SAARTEXT_END>"/ |
  sed -nr '/SAARTEXT_START/,/SAARTEXT_END/p' |
  sed -e 's/<[^>]*>//g' |
  uniq
