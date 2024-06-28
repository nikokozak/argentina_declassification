#!/bin/bash

docker run -it --rm -p 7700:${MEILISEARCH_PORT:=6969} getmeili/meilisearch:latest meilisearch --master-key=$MEILISEARCH_API_KEY
