#!/bin/bash
#
#  Build script for FCT
#

export VERSION=$(./gen_version.sh)
export FCT_STICKER=fct_sticker.xml
export NEED_VERSION=07.20.3226

python vadpacker/vadpacker.py \
    -o fct_dav.vad \
    --var="VERSION=$VERSION" \
    --var="BASE_PATH=/DAV/VAD" \
    --var="TYPE=dav" \
    --var="ISDAV=1" \
    --var="NEED_VERSION=$NEED_VERSION" \
    $FCT_STICKER

ls -l fct_dav.vad
