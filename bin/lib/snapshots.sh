#! /usr/bin/env bash

# This file contains shell functions for working with snapshot tags.
#
# A snapshot tag is a docker image tag assigned to CiviForm images when they are
# are first pushed to Docker Hub. All commits in the main CiviForm branch get an
# image tag of the form:
#
# 'SNAPSHOT-[git short commit SHA]-[timestamp in unix seconds]'
#
# See https://github.com/seattle-uat/civiform/blob/main/bin/build-and-push

# Matches a CiviForm snapshot tag with a capture group for the commit short SHA.
readonly CIVIFORM_SNAPSHOT_TAG_REGEX="^SNAPSHOT\-([a-zA-Z0-9]+)\-[0-9]+$"

#######################################
# Predicate function that checks if a string is formatted
# as a CiviForm server image snapshot tag.
# Arguments:
#   1: The string to test.
#######################################
function snapshots::tag_is_snapshot() {
  local full_tag="${1}"

  [[ "${full_tag}" =~ ${CIVIFORM_SNAPSHOT_TAG_REGEX} ]]
}

#######################################
# Parses a snapshot tag and emits the git short SHA portion of it.
# Arguments:
#   1: The snapshot tag.
#######################################
function snapshots::get_git_commit_sha() {
  local full_tag="${1}"

  [[ "${full_tag}" =~ ${CIVIFORM_SNAPSHOT_TAG_REGEX} ]]
  echo "${BASH_REMATCH[1]}"
}
