#!/usr/bin/env bash
set -euo pipefail

# Default values
JENKINS_URL=""
JOB_NAME=""
PARAMS=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --url)
      JENKINS_URL="$2"
      shift 2
      ;;
    --job)
      JOB_NAME="$2"
      shift 2
      ;;
    --param)
      PARAMS="${PARAMS}&${2}"
      shift 2
      ;;
    *)
      echo "Unknown parameter: $1"
      exit 1
      ;;
  esac
done

# Validate required parameters
if [ -z "$JENKINS_URL" ] || [ -z "$JOB_NAME" ]; then
  echo "Usage: $0 --url JENKINS_URL --job JOB_NAME [--param KEY=VALUE]..."
  exit 1
fi

# Check for Jenkins credentials
if [ -z "${JENKINS_USER:-}" ] || [ -z "${JENKINS_TOKEN:-}" ]; then
  echo "Error: JENKINS_USER and JENKINS_TOKEN environment variables must be set"
  exit 1
fi

# Trigger the build
BUILD_URL="${JENKINS_URL}/job/${JOB_NAME}/buildWithParameters?${PARAMS#&}"
echo "Triggering build: $BUILD_URL"
curl -sS -X POST \
  --user "$JENKINS_USER:$JENKINS_TOKEN" \
  "$BUILD_URL"