#! /bin/bash

find . -iname \*-ipadhd.*png | awk '{print("./resize.sh "$1"")}' | /bin/bash

# the arrows are too small on the iPhone devices
cp ./Resources/arrow-ipadhd.png ./Resources/arrow-hd.png
cp ./Resources/arrow-ipad.png ./Resources/arrow.png