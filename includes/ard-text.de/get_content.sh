#!/bin/bash

page=$1
subpage=$2

curl -s "https://www.ard-text.de/index.php?page=$page\&sub=$subpage" |
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
  awk '
    function h2i(h,   i,c,v) {
      v=0; h=tolower(h)
      for (i=1; i<=length(h); i++) {
        c=substr(h,i,1)
        v=v*16+(c>="a" ? index("abcdef",c)+9 : c+0)
      }
      return v
    }
    function tb(x,   tl,tr,ml,mr,bl,br,p,d) {
      tl=int(x)%2;   tr=int(x/2)%2
      ml=int(x/4)%2; mr=int(x/8)%2
      bl=int(x/16)%2; br=int(x/64)%2
      p=tl+tr*2+ml*4+mr*8+bl*16+br*32
      if (p== 0) return " "
      if (p==63) return "█"
      if (p== 3) return "▀";  if (p==48) return "▄"
      if (p==21) return "▌";  if (p==42) return "▐"
      if (p== 1) return "▘";  if (p== 2) return "▝"
      if (p==16) return "▖";  if (p==32) return "▗"
      if (p==33) return "▚";  if (p==18) return "▞"
      if (p==19) return "▛";  if (p==50) return "▟"
      if (p==35) return "▜";  if (p==49) return "▙"
      d=tl+tr+ml+mr+bl+br
      if (d>=4) return "▓"; if (d==3) return "▒"; return "░"
    }
    {
      line=$0; result=""
      while (match(line, /g[0-9a-z]+[.]gif/)) {
        seg=substr(line,RSTART,RLENGTH)
        if (seg~/^g1w[0-9a-f]+[.]gif$/)
          ch=tb(h2i(substr(seg,4,length(seg)-7)))
        else
          ch="·"
        result=result substr(line,1,RSTART-17) ch
        line=substr(line,RSTART+RLENGTH+2)
      }
      print result line
    }
  ' |
  sed -e 's/<[^>]*>//g' |
  uniq |
  awk 'BEGIN{n=0} NF{n=1} {print} END{if(!n) print "  Seite nicht gefunden."}'
