#! /usr/bin/env bash

#######################################
# Retrieves the image tag from a list of aguments.
# Exits with an error message if --tag flag is not found.
# Arguments:
#   @: An arguments list
# Globals:
#   Sets the IMAGE_TAG variable
#######################################
function get_cmd_args::get_image_tag() {
  for i in "$@"; do
    case "${i}" in
      --tag=*)
        export IMAGE_TAG="${i#*=}"
        return
        ;;
    esac
  done

  out::error "--tag argument is required"
  exit 1
}

#######################################
# Retrieves the config file name from a list of aguments if present.
# Arguments:
#   @: An arguments list
# Globals:
#   Sets the CONFIG_FILE variable
#######################################
function get_cmd_args::get_config_file() {
  for i in "$@"; do
    case "${i}" in
      --config=*)
        export CONFIG_FILE="${i#*=}"
        return
        ;;
    esac
  done

  export CONFIG_FILE="civiform_config.sh"
}

get_cmd_args::get_image_tag "$@"
get_cmd_args::get_config_file "$@"
