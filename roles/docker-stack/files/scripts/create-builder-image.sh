#!/usr/bin/env bash

## ref: https://nextbreakpoint.com/posts/article-compile-code-with-docker.html
mkdir build-autotools-image

cat <<EOF >build-autotools-image/Dockerfile
FROM ubuntu:18.04
RUN apt-get update -y && apt-get -y install git make gcc autoconf nasm yasm pkg-config
EOF

docker build -t build-autotools build-autotools-image

mkdir output

docker run -it --rm -v $(pwd)/output:/output build-autotools git clone https://github.com/FFmpeg/FFmpeg.git /output/ffmpeg
docker run -it --rm -v $(pwd)/output:/output build-autotools bash -c "cd /output/ffmpeg && ./configure --enable-gpl --disable-ffserver && make"
