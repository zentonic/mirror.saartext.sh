#!/bin/bash

page=$1
subpage=$2

curl -s "https://www.ard-text.de/index.php?page=$page\&subpage=$subpage" |
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
