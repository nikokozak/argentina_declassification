# TODO:

- IMPORT SYSTEM APP - URGENT
- SEARCH BY COLLECTION
- Import system w/sha hashing to verify similarity in docs.
- Track status of individual files via struct.

    - Needs:
    a) has this set been imported yet?
    b) if so, does it have the same amount of files?
    c) if so, are all the files the same?
    d) if not (b | c):
        - import the set files
        - rewrite index on import (but NOT ID)
        - update docs in search engine

- How to standardize actual archive (mix task)?
    - Write tests for logic module and ingesting.
    - Keep track of ingest with a hidden file (so we don't duplicate stuff)
    - Output (including text) is written, using output schema.

- How to pass in info to Mielesarch?
    - Pass in data to search engine.


