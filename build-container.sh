#!/bin/bash

# Environment variables (flags)
IMAGE_NAME="alpine-hugo-server"
CONTEXT="."
CONTAINERFILE="Containerfile"
BUILD_ARGS=""
TAG_FILE="tag.txt"
REGISTRY_URL="harbor.haow.fi"
PROJECT_NAME="addei"
REGISTRY_IMAGE="${REGISTRY_URL}/${PROJECT_NAME}/${IMAGE_NAME}"

PUSH_IMAGE=false
CLEAN_IMAGES=false

# Parse arguments
for arg in "$@"; do
  case $arg in
    --major)
      MAJOR_BUMP=true
      ;;
    --push)
      PUSH_IMAGE=true
      ;;
    --clean)
      CLEAN_IMAGES=true
      ;;
  esac
done

# Clean old images if requested
if [[ "$CLEAN_IMAGES" == "true" ]]; then
  echo "Removing old local images for ${IMAGE_NAME} and ${REGISTRY_IMAGE}..."
  podman images | grep "${IMAGE_NAME}" | awk '{print $3}' | xargs -r podman rmi -f
  echo "Pruning unused images..."
  podman image prune -a -f
fi

# Read the last tag from file or start with v1.0
if [[ -f "$TAG_FILE" ]]; then
  last_tag=$(cat "$TAG_FILE")
else
  last_tag="v1.0"
fi

major=$(echo "$last_tag" | cut -d. -f1 | tr -d 'v')
minor=$(echo "$last_tag" | cut -d. -f2)

# Version bump logic
if [[ "$MAJOR_BUMP" == "true" ]]; then
  major=$((major + 1))
  minor=0
else
  minor=$((minor + 1))
fi

TAG="v${major}.${minor}"

# Save the new tag to file
echo "$TAG" > "$TAG_FILE"

# Build the container image with both local and REGISTRY tags
podman build \
  -t "${IMAGE_NAME}:${TAG}" \
  -t "${REGISTRY_IMAGE}:${TAG}" \
  -f "${CONTAINERFILE}" \
  ${BUILD_ARGS} \
  "${CONTEXT}"

echo "Container image '${IMAGE_NAME}:${TAG}' and '${REGISTRY_IMAGE}:${TAG}' built successfully."

# Push to REGISTRY if requested
if [[ "$PUSH_IMAGE" == "true" ]]; then
  podman push "${REGISTRY_IMAGE}:${TAG}"
  echo "Image pushed to ${REGISTRY_IMAGE}:${TAG}"
fi