#! /usr/bin/env bash

#######################################
# Retrieves the value of given flags, if present, and
# sets a default for some variables if they should have one.
#######################################

# Defaults
export CONFIG="civiform_config.sh"

# Parse flags
for i in "$@"; do
  case "${i}" in
    --config=*)
      export CONFIG="${i#*=}"
      ;;
    --force-unlock=*)
      export FORCE_UNLOCK_ID="${i#*=}"
      ;;
  esac
done
