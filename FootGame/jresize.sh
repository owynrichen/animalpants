#! /bin/bash

ipad=`echo $1 | sed 's/-ipadhd/-ipad/'`
hd=`echo $1 | sed 's/-ipadhd/-hd/'`
phone=`echo $1 | sed 's/-ipadhd//'`

convert -resize 50% -quality 80 $1 $ipad
convert -resize 41.666666% -quality 80 $1 $hd
convert -resize 20.833333% -quality 80 $1 $phone