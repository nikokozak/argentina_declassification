#!/bin/bash
# Given a directory as its only argument, takes said directory and:
# 1. Creates an output directory.
# 2. Runs ocrmypdf on all pdf files in said directory in parallel.
# 3. Runs pdftotext on all OCR'd files in the output directory.

# Ask for user confirmation if an output folder already exists.
if [ -d "$1/output" ]
then
    read -p "An output directory was found - are you sure you want to continue? [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi
fi

mkdir "$1/output"

# Run ocrmypdf in parallel using 2 cores.
parallel --tag -j 8 ocrmypdf '{}' "$1/output/{/}" ::: $1/*.pdf

# Sequentially run pdftotext on all pdf files in the output dir.
# Then run imagemagick to get thumbnails.
# pdftotext has options including html descriptors of word locations on the output pdf.
for f in $1/output/*.pdf
do
    echo $f
    pdftotext -raw "$f"
    convert -thumbnail x800 -background black -alpha remove "$f[0]" "${f%.pdf}.png"
done

echo
echo "Finished processing all files."
echo
