#! /bin/bash
echo cp "/Users/orichen/Dropbox/Animals\ App\ illustrations/$1" "bg-ipadhd.jpg"
cp /Users/orichen/Dropbox/Animals\ App\ illustrations/$1 bg-ipadhd.jpg
png=bg_$2-ipadhd.png

convert -format PNG -quality 5 bg-ipadhd.jpg $png
../../../../resize.sh $png
rm bg-ipadhd.jpg