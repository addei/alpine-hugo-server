#!/bin/sh
# Creator: Atte - https://github.com/addei 


# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
REPO_URL="https://github.com/gohugoio/hugo.git"
BUILD_DIR="./hugo-build"
OUTPUT_BINARY="hugo"
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
BRANCH=stable


# Display step information
echo "=== Starting Hugo build process ==="
echo "Build Date: $BUILD_DATE"

# Step 1: Clone the Hugo repository
if [ ! -d "$BUILD_DIR" ]; then
  echo "Cloning Hugo repository..."
  git clone $REPO_URL $BUILD_DIR
  cd $BUILD_DIR
  git checkout $BRANCH
  cd -
else
  echo "Repository already exists. Pulling latest changes..."
  cd $BUILD_DIR
  git pull
  git checkout $BRANCH
  cd -
fi

# Step 2: Navigate to the build directory
cd $BUILD_DIR

# Step 3: Initialize go.mod if necessary
if [ ! -f "go.mod" ]; then
  echo "Initializing Go module..."
  go mod init github.com/gohugoio/hugo
fi

# Step 4: Tidy up dependencies
echo "Tidying up dependencies..."
go mod tidy

# Step 5: Build the Hugo binary
echo "Building Hugo binary..."
CGO_ENABLED=1 go build -v -tags "extended,withdeploy" -ldflags "-X github.com/gohugoio/hugo/common.BuildDate=$BUILD_DATE" -o $OUTPUT_BINARY

# Step 6: Display build success
echo "Hugo binary built successfully: $(pwd)/$OUTPUT_BINARY"

# Step 7: Optional - Display Hugo version
echo "Checking Hugo version..."
./$OUTPUT_BINARY version

# Step 8: Exit and cleanup
echo "=== Build process completed ==="

exit 0
