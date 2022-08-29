#!/bin/bash

docker run -it --rm -p 7700:$MEILISEARCH_PORT getmeili/meilisearch:latest meilisearch --master-key=$MEILISEARCH_API_KEY
