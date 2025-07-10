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

### Automated build with versioning and registry push

You can use the provided `build-container.sh` script to automatically build the container image and handle version tagging. The script reads the current version tag from the `tag.txt` file, increments it (minor or major), and writes the new tag back to `tag.txt` after each build.  
It also tags the image for your self-hosted registry (`registry.haow.fi/addei/alpine-hugo-server`).  
You can optionally push the image to the registry and clean old local images with script flags.

**First-time setup:**  
Create the `tag.txt` file with the starting value:
```
echo "v1.1" > tag.txt
```

**To build and increment the minor version:**
```
./build-container.sh
```

**To increment the major version (resets minor to 0):**
```
./build-container.sh --major
```

**To push the image to the registry after build:**
```
./build-container.sh --push
```

**To clean old local images before building:**
```
./build-container.sh --clean
```

Flags can be combined, for example:
```
./build-container.sh --push --clean
```

The script will build the image and tag it as both `alpine-hugo-server:vX.Y` and `registry.haow.fi/addei/alpine-hugo-server:vX.Y` (e.g., `v1.2`, `v2.0`), updating `tag.txt`

## Running the container (Fedora/SELinux)

If you are running Fedora with SELinux enabled, you need to add the `:z` or `:Z` option to your volume mount to set the correct SELinux context for the container to access the mounted files.

**Example Podman run command:**

```sh
podman run --name alpine-hugo-dev-server \
  -p 8080:80 \
  -v /var/home/addei/Desktop/my-blog:/checkout:Z \
  -it harbor.haow.fi/addei/alpine-hugo-server:v1.2 sh
```

- `--name alpine-hugo-dev-server`: Sets the container name.
- `-p 8080:80`: Forwards host port 8080 to container port 80.
- `-v /var/home/addei/Desktop/my-blog:/checkout:Z`: Mounts your blog directory with the correct SELinux context for container access.
- `-it`: Runs the container interactively with a TTY.
- `sh`: Starts a shell inside the container.
- `registry.haow.fi/addei/alpine-hugo-server:v1.2`: The image to run (replace `v1.2` with your current tag if needed).

> **Tip:**  
> Use `:Z` for a single container, or `:z` if you want multiple containers to share the volume.

---
**If you see permission errors when mounting volumes, always check your SELinux context and use the `:Z` or `:z` option as shown above.**