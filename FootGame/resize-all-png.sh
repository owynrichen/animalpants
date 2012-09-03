#! /bin/bash

find . -iname \*-ipadhd.png | awk '{print("./resize.sh "$1"")}' | /bin/bash