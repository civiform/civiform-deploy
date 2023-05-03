#! /usr/bin/env bash

# This file contains shell functions for working with the mainline project
# checkout. Almost all commands in this deployment repo delegate their
# implementation to code in the mainline CiviForm repo's cloud/ subtree.
#
# Which git revision the scripts should use for that depends on the docker image
# tag the user specifies in the command.

#######################################
# Delegates a command from a specified path to the main CiviForm repo at a
# specific git revision.
# Expects arguments to include "--tag=<tag name>" for resolving which revsion
# to check out for the command. Then passes all arguments to the delegated
# command in the main repo.
# Arguments:
#   @: arguments for the command, must include --tag= flag
# Globals:
#   CMD_NAME: the name of the command to run
#######################################
function checkout::exec_delegated_command_at_path() {
    if [[ -z ${CMD_NAME_PATH} ]]; then
        out::error "CMD_NAME must be set for delegated command."
        exit 1
    fi

    if [[ -z ${CIVIFORM_VERSION} ]]; then
        out::error "CIVIFORM_VERSION needs to be either 'latest' or a version from https://github.com/civiform/civiform/releases"
        exit 1
    fi
    if [[ ${CIVIFORM_VERSION} == 'latest' && ${CIVIFORM_MODE} == 'prod' ]]; then
        out::error "For production deployments, CIVIFORM_VERSION needs to be a version from https://github.com/civiform/civiform/releases"
        exit 1
    fi

    checkout::initialize
    if [[ -z ${CIVIFORM_CLOUD_DEPLOYMENT_VERSION} ]]; then
        out::error "CIVIFORM_CLOUD_DEPLOYMENT_VERSION needs to be set to 'latest' or commit sha from https://github.com/civiform/cloud-deploy-infra."
        exit 1
    else
        checkout::at_sha "${CIVIFORM_CLOUD_DEPLOYMENT_VERSION}"
    fi

    checkout::initialize_python_env
    (
        cd checkout
        CONFIG_FILE_ABSOLUTE_PATH="${CONFIG}"
        if [[ ${CONFIG:0:1} != "/" ]]; then
            CONFIG_FILE_ABSOLUTE_PATH="../${CONFIG}"
        fi
        args=("--command=${CMD_NAME}" "--tag=${CIVIFORM_VERSION}" "--config=${CONFIG_FILE_ABSOLUTE_PATH}")
        echo "Running ${CMD_NAME_PATH} ${args[@]}"
        exec "${CMD_NAME_PATH}" "${args[@]}"
    )
}

#######################################
# Delegates a command from the shared bin to the main CiviForm repo at a
# specific git revision.
# Expects arguments to include "--tag=<tag name>" for resolving which revsion
# to check out for the command. Then passes all arguments to the delegated
# command in the main repo.
# Arguments:
#   @: arguments for the command, must include --tag= flag
# Globals:
#   CMD_NAME: the name of the command to run
#######################################
function checkout::exec_delegated_command() {
    CMD_NAME_PATH="cloud/shared/bin/run.py" \
        checkout::exec_delegated_command_at_path "$@"
}

#######################################
# Initializes the checkout directory by initializing a git repo, setting its
# origin to the mainline CiviForm repo, and configuring a sparse checkout
# that only contains the cloud/ directory.
#######################################
function checkout::initialize() {
    printf "Initializing checkout... "

    rm -rf checkout
    mkdir checkout

    pushd checkout > /dev/null

    git init --initial-branch=main
    git remote add origin http://github.com/civiform/cloud-deploy-infra
    git config core.sparseCheckout true

    echo "/cloud" >> .git/info/sparse-checkout
    echo "/bin" >> .git/info/sparse-checkout

    git pull --quiet origin main

    popd > /dev/null
    echo "done"
}

#######################################
# Sets the checkout directory to the commit at the provided SHA.
# Pulls the latest git revisions first.
# Arguments:
#   1: The commit SHA to sync to.
#######################################
function checkout::at_sha() {
    local commit_sha="${1}"
    if [[ ${commit_sha} == 'latest' ]]; then
        checkout::at_main
    else
        printf "Setting checkout to ${commit_sha}... "

        pushd checkout > /dev/null

        git pull --quiet origin main
        git checkout --quiet "${commit_sha}"

        popd > /dev/null
        echo "done"
    fi
}

#######################################
# Pulls the latest git revisions for the checkout directory from the mainline
# CiviForm repo.
#######################################
function checkout::at_main() {
    printf "Syncing checkout directory to latest commit... "

    pushd checkout > /dev/null

    git checkout --quiet main
    git pull --quiet origin main

    popd > /dev/null
    echo "done"
}

#######################################
# Initializes a python venv and installs required dependencies to run
# cloud-deploy-infra python files. The cloud-deploy-infra repository must be
# already cloned into checkout directory before calling this function.
#
# Creates the venv outside of the checkout directory because the checkout
# directory is deleted on every run (see checkout::initialize).
#######################################
function checkout::initialize_python_env() {
    if [[ ! -f checkout/cloud/requirements.txt ]]; then
        echo "cloud-deploy-infra version checked out does not have a requirements.txt file, no python setup is needed"
        return
    fi

    if [[ -d .venv ]]; then
        source .venv/bin/activate
        if [[ ! $(pip freeze | diff checkout/cloud/requirements.txt -) ]]; then
            echo ".venv directory found with necessary dependencies installed"
            return
        fi

        echo ".venv directory found but necessary dependencies are not installed, installing..."
        pip install -r checkout/cloud/requirements.txt
        return
    fi

    echo ".venv directory not found, creating and installing dependencies..."
    python3 -m venv .venv
    pip install -r checkout/cloud/requirements.txt
}
