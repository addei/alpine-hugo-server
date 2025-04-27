# alpine-hugo-server
Repository for building Alpine Linux container image with Hugo server built from source.

Note: If you use my work, please refer also to this repository and give credits where credits are due. Thank you! :)

## Containerfile

This containerfile defines a multi-stage build process for compiling and installing the Hugo binary into an Alpine Linux container.
1. Builder Stage:
    - Installs required dependencies (go, g++, git).
    - Creates a working directory (/temp/hugo) and sets it as the build location.
    - Copies the build-hugo.sh script, makes it executable, and runs it to build the Hugo binary.
2. Final Stage:
    - Copies the built Hugo binary from the builder stage into /usr/bin/ for system-wide use.
    - Cleans up temporary files.
    - Installs gcompat and libstdc++ to ensure compatibility and resolve library dependencies.
    - Checks if hugo installed correctly

## build-hugo.sh

This script automates the process of building the Hugo static site generator. It:
- Clones the Hugo repository (or pulls updates if it already exists).
- Checks out the stable branch.
- Initializes and tidies Go modules if required.
- Builds the Hugo binary with SCSS support (extended) and deployment features.
- Sets a dynamic build date using linker flags.
- Outputs the binary and verifies the build.

### Environment Variables
    - $REPO_URL: Repository URL for Hugo (https://github.com/gohugoio/hugo.git).
    - $BUILD_DIR: Directory where the source code is cloned (./hugo-build).
    - $OUTPUT_BINARY: Name of the final built binary (hugo).
    - $BUILD_DATE: Dynamic build date in ISO8601 format.
    - $BRANCH: Git branch to check out ('stable' by default, can be also set as master (latest)).

## Podman build command

```
podman buildx build --platform linux/amd64,linux/arm64 \
    --push \
    --tag your-registry/alpine-hugo-server:tag \
    .
```