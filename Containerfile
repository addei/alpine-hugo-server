#  Creator: Atte - https://github.com/addei

FROM alpine:latest AS builder

# Project build directory
ENV BUILD_DIR /temp/hugo

# Install dependencies for building hugo
RUN ["apk", "add", "go", "g++", "git"]

# Create and set the working directory
RUN mkdir -p $BUILD_DIR
WORKDIR $BUILD_DIR

# Copy build-hugo.sh to builder container
COPY build-hugo.sh .

# Make the file executable
RUN chmod +x ./build-hugo.sh

# Run build-hugo.sh
RUN ./build-hugo.sh

FROM alpine:latest

# Install dependencies for building hugo
RUN ["apk", "git"]

ENV BUILD_DIR /temp/hugo

# Set temp location for hugo binary
WORKDIR /temp
COPY --from=builder ${BUILD_DIR}/hugo-build/hugo .

# Install binary to system default binary path and 
RUN install -m 755 hugo /usr/bin/hugo
RUN rm -rf hugo

# Install GNU C Library and GNU C++ standard libraries
RUN apk add --no-cache gcompat libstdc++

# Verify library dependencies
RUN ldd /usr/bin/hugo

# Check if hugo runs from default path
RUN hugo version

# Set the environment variables for JVM options
ENV ENVIRONMENT="live"
ENV BIND="0.0.0.0"
ENV BASE_URL="localhost"
ENV APPEND_PORT="false"

# Set WORKDIR and add CMD
WORKDIR /checkout
CMD hugo server -s hugo --appendPort=${APPEND_PORT} -e ${ENVIRONMENT} --bind ${BIND} --baseURL ${BASE_URL} --buildDrafts
