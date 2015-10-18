#!/bin/sh
DIRNAME=`dirname $1`
FILENAME=`basename $1`
ls $DIRNAME/*.tar.xz | sort  | while read fname; do 
  WNAME=`basename $fname`
  if [ "$WNAME" \< "$FILENAME" ] 
  then 
    if [ "$2" \= "" ] 
    then
       tar -xJGf  "$fname"
    else 
       mkdir "$2"
       tar -C "$2"  -xJGf  "$fname"
    fi
  fi
  if [ "$2" \= "" ] 
    then
       tar -xJGf  "$fname"
    else 
       tar -C "$2"  -xJGf  "$fname"
    fi
done
