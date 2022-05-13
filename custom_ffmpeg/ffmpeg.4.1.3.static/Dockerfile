FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video

RUN apt-get update \
    && apt-get -y --no-install-recommends install build-essential curl ca-certificates python3 python-is-python3 ninja-build meson \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && update-ca-certificates

WORKDIR /app

COPY ./build-ffmpeg /app/build-ffmpeg
RUN chmod +x /app/build-ffmpeg
# PATCH
COPY patch /tmp/ffmpeg_patch/

ENV FFMPEG_VERSION=4.1.3
RUN AUTOINSTALL=yes /app/build-ffmpeg --build --full-static --enable-gpl-and-non-free

# Check shared library
RUN ! ldd /app/workspace/bin/ffmpeg
RUN ! ldd /app/workspace/bin/ffprobe
RUN ! ldd /app/workspace/bin/ffplay
