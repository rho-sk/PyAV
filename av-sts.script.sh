#!/usr/bin/env bash

export PYAV_LIBRARY=ffmpeg-4.1.3
source scripts/activate.sh
pip3 install --upgrade -r tests/requirements.txt
make
python3 setup.py  bdist_wheel

