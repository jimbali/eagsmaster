#!/bin/sh
CONTENT_TYPE="application/vnd.docker.distribution.manifest.list.v2+json"
read -p 'Username: ' USERNAME
read -s -p 'Password: ' PASSWORD
echo  ''
read -p 'Repo: ' INPUT_REPO
read -p 'Old tag: ' INPUT_OLD_TAG
read -p 'New tag: ' INPUT_NEW_TAG

TOKEN="$(curl -s -u "${USERNAME}:${PASSWORD}" "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${INPUT_REPO}:pull,push" | jq --raw-output .token)"
curl -s -H "Accept: ${CONTENT_TYPE}" -H "Authorization: Bearer ${TOKEN}" "https://index.docker.io/v2/${INPUT_REPO}/manifests/${INPUT_OLD_TAG}" > manifest.json
curl -X PUT -H "Content-Type: $CONTENT_TYPE" -H "Authorization: Bearer $TOKEN" -d @manifest.json "https://index.docker.io/v2/${INPUT_REPO}/manifests/${INPUT_NEW_TAG}"
rm manifest.json
