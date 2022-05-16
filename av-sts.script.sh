#!/usr/bin/env bash

mkdir -p /home/pyav_builder
cp -r . /home/pyav_builder
cd /home/pyav_builder

export PYAV_LIBRARY=ffmpeg-4.1.6
source scripts/activate.sh
pip3 install --upgrade -r tests/requirements.txt
make
python3 setup.py  bdist_wheel

mkdir -p /home/pyav/dist
cp -f /home/pyav_builder/dist/*.*  /home/pyav/dist
rm -rf  /home/pyav_builder

