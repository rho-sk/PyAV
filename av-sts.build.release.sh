#!/usr/bin/env bash

IMAGE_VERSION=ffmpeg_patched:4.1.6

docker run -v $(pwd):/home/pyav  $IMAGE_VERSION  /bin/bash -c "cd /home/pyav && bash ./av-sts.script.sh"