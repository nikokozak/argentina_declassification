#!/bin/bash
for f in $1/*.pdf
do
    echo $f
    convert -thumbnail x800 -background black -alpha remove "$f[0]" "${f%.pdf}.png"
done
