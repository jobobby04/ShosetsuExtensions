#!/bin/bash
set -euo pipefail

## Parse command line arguments
DOWNLOAD_DOC=false
DOWNLOAD_TESTER=false

if [ "$#" -eq 0 ]; then
  DOWNLOAD_DOC=true
  DOWNLOAD_TESTER=true
else
  for arg in "$@"; do
    case $arg in
      --doc)
        DOWNLOAD_DOC=true
        ;;
      --tester)
        DOWNLOAD_TESTER=true
        ;;
      *)
        echo "Unknown argument: $arg"
        exit 1
    esac
  done
fi

if [ "$DOWNLOAD_DOC" = true ]; then
  ## Download lua documentation
  wget -O _doc.lua https://gitlab.com/shosetsuorg/kotlin-lib/-/raw/main/_doc.lua

  ## Download javascript documentation
  #wget -O doc.js https://gitlab.com/shosetsuorg/kotlin-lib/-/raw/main/doc.js
fi

if [ "$DOWNLOAD_TESTER" = true ]; then
  ## Download extension tester
  mkdir -p bin
  wget -O bin/extension-tester.jar "https://gitlab.com/shosetsuorg/extension-tester/-/jobs/artifacts/development/raw/build/libs/extension-tester.jar?job=build"
fi