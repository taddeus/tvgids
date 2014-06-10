#!/bin/sh
hash inotifywait || (echo "Install inotify-tools first"; exit 1)

make

while true; do
    inotifywait --quiet --event attrib,modify *.sass *.coffee
    sleep 0.05s
    make
done
