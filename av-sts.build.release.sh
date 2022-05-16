#!/usr/bin/env bash

IMAGE_VERSION=ffmpeg_patched:4.1.3

docker run -it $IMAGE_VERSION  -v $(pwd):/home/pyav  /bin/bash -c "cd /home/pyav && bash ./av-sts.script.sh"