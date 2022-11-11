#! /usr/bin/env bash

#######################################
# Retrieves the config file name from a list of aguments if present.
# Arguments:
#   @: An arguments list
# Globals:
#   Sets the CONFIG variable
#######################################
function get_cmd_args::get_config_file() {
  for i in "$@"; do
    case "${i}" in
      --config=*)
        export CONFIG="${i#*=}"
        return
        ;;
    esac
  done

  export CONFIG="civiform_config.sh"
}

get_cmd_args::get_config_file "$@"
