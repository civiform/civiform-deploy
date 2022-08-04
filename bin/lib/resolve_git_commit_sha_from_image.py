#! /usr/bin/env python3

'''
Contains functions for validating and resolving image tags.
'''

import argparse
import json
import os
import re
import urllib.error
import urllib.request
import sys

_CIVIFORM_RELEASE_TAG_REGEX = re.compile(r'^v[0-9]+\.[0-9]+\.[0-9]+$')

_DOCKERHUB_REGISTRY_URL = 'https://registry-1.docker.io/v2'


class _TagOrDigestDoesNotExistError(Exception):

    def __init__(self, tag_or_digest):
        super().__init__(f'"{tag_or_digest}" could not be found in DockerHub.')


class _NoGitCommitInfoError(Exception):

    def __init__(self, tag_or_digest):
        super().__init__(
            f'Git commit information could not be obtained for "{tag_or_digest}"')


def _check_for_unsupported_tag(tag_or_digest):
    if _CIVIFORM_RELEASE_TAG_REGEX.match(tag_or_digest):
        return True

    # Warn the user that this tag type may not be stable and prompt them
    # to continue.
    sys.stderr.write(f'''
The provided tag "{tag_or_digest}" does not reference a release tag and may not
be stable.
''')
    if os.getenv('CF_SKIP_WARN'):
        sys.stderr.write(
            'Proceeding automatically since the "CF_SKIP_WARN" environment variable was set.')
        return True
    sys.stderr.write(f'''
If you would like to continue deployment, please type YES below.

Continue: ''')
    resp = input()
    return resp.lower().strip() == 'yes'


def _get_auth_token():
    resp = urllib.request.urlopen(
        f'https://auth.docker.io/token?scope=repository:civiform/civiform:pull&service=registry.docker.io')
    if resp.status != 200:
        raise ValueError(
            f'Unexpected error retrieving an auth token: Status code: {resp}')
    return json.loads(resp.read()).get('token', '')


def _resolve_to_digest(tag_or_digest):
    # Note: If the provided value is already a digest, we still perform the below
    # call in order to ensure we're referencing a valid version on DockerHub.
    req = urllib.request.Request(
        f'{_DOCKERHUB_REGISTRY_URL}/civiform/civiform/manifests/{tag_or_digest}')
    auth_token = _get_auth_token()
    req.add_header('Authorization', f'Bearer {auth_token}')
    req.add_header(
        'Accept', 'application/vnd.docker.distribution.manifest.v2+json')
    try:
        resp = urllib.request.urlopen(req)
    except urllib.error.HTTPError as e:
        if e.status == 404:
            raise _TagOrDigestDoesNotExistError(tag_or_digest)
        raise e

    json_resp = json.loads(resp.read())
    return json_resp['config']['digest']


def _extract_git_commit_sha(tag_or_digest):
    digest = _resolve_to_digest(tag_or_digest)
    if digest is False:
        raise ValueError(f'Could not resolve {tag_or_digest}')

    req = urllib.request.Request(
        f'{_DOCKERHUB_REGISTRY_URL}/civiform/civiform/blobs/{digest}')
    auth_token = _get_auth_token()
    req.add_header('Authorization', f'Bearer {auth_token}')
    try:
        resp = urllib.request.urlopen(req)
    except urllib.error.HTTPError as e:
        raise _TagOrDigestDoesNotExistError(tag_or_digest)

    json_resp = json.loads(resp.read())
    git_commit_sha = json_resp['config'].get(
        'Labels', {}).get('civiform.git.commit_sha', None)
    if not git_commit_sha:
        raise _NoGitCommitInfoError(tag_or_digest)

    return git_commit_sha


_parser = argparse.ArgumentParser()
_parser.add_argument('--tag', required=True,
                     help='A Docker tag (or digest) indicating the version of the civiform/civiform image to deploy.')

if __name__ == '__main__':
    args = _parser.parse_args()

    if not _check_for_unsupported_tag(args.tag):
        sys.exit(1)

    try:
        print(_extract_git_commit_sha(args.tag), file=sys.stdout)
    except (_NoGitCommitInfoError, _TagOrDigestDoesNotExistError) as e:
        print(f'Error: {e}', file=sys.stderr)
        sys.exit(1)
