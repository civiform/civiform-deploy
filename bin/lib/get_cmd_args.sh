#! /usr/bin/env bash

#######################################
# Retrieves the config file name from a list of aguments if present.
# Arguments:
#   @: An arguments list
# Globals:
#   Sets the CONFIG variable
#######################################
function get_cmd_args::verify_config_file_exists() {
  if [[ ! -f "${CONFIG}" ]]; then
      echo "Config file named '${CONFIG}' was not found."
      echo
      echo "Create a file named civiform_config.sh or use the --config argument to specify a different file name."
      exit 1
  fi
}

function get_cmd_args::verify_cert_file_exists() {
  if [[ -z "${CERT_FILE}" || ! -r "${CERT_FILE}" ]]; then
    echo "Certificate file '${CERT_FILE}' was not found or is not readable."
    exit 1
  fi
}

function get_cmd_args::get_args() {
  for i in "$@"; do
    case "${i}" in
      --config=*)
        export CONFIG="${i#*=}"
        get_cmd_args::verify_config_file_exists
        ;;
      --cert=*) 
        export CERT_FILE="${i#*=}"
        echo "Certificate file specified: ${CERT_FILE}"
        get_cmd_args::verify_cert_file_exists
        ;;
    esac
  done

  # If we set CONFIG in config::choose, or it's already been set, use that.
  # Otherwise, default to civiform_config.sh.
  if [[ -z "${CONFIG}" ]]; then
    export CONFIG="civiform_config.sh"
  fi
  get_cmd_args::verify_config_file_exists
}

get_cmd_args::get_args "$@"
