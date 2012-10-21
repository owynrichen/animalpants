#! /bin/bash

# TODO: fix this to work with non-pngs..
ipad=`echo $1 | sed 's/-ipadhd/-ipad/' | sed 's/.png//'`
hd=`echo $1 | sed 's/-ipadhd/-hd/' | sed 's/.png//'`
phone=`echo $1 | sed 's/-ipadhd//' | sed 's/.png//'`

convert -resize 50% -quality 5 $1 $ipad
convert -resize 41.666666% -quality 5 $1 $hd
convert -resize 20.833333% -quality 5 $1 $phone
mv $1 $1.tmp
pngcrush $1.tmp $1
pngcrush $ipad $ipad.png
pngcrush $hd $hd.png
pngcrush $phone $phone.png
rm $1.tmp
rm $ipad
rm $hd
rm $phone