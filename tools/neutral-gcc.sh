#!/bin/sh
#
# neutral-gcc.sh: gcc with neutral build paths, for builds whose own make
# system has no place for extra flags (illumos-drm series-dc, gfx-drm, ...):
#   CC=/path/to/neutral-gcc.sh  (NEUTRAL_GCC: the real gcc, default gcc)
#   NEUTRAL_WS: the workspace, mapped to NEUTRAL_WS_NAME (default: its
#   basename); everything else under $HOME maps to /build.
# GCC and gas use the last matching map, so the workspace map comes last.
#
# Copyright 2026 isoriano1968. CDDL-1.0.
#
ws=${NEUTRAL_WS:-${CODEMGR_WS:-$PWD}}
name=${NEUTRAL_WS_NAME:-$(basename "$ws")}
exec ${NEUTRAL_GCC:-gcc} \
    -ffile-prefix-map="$HOME"=/build \
    -ffile-prefix-map="$ws"="$name" \
    -Wa,--debug-prefix-map,"$HOME"=/build \
    -Wa,--debug-prefix-map,"$ws"="$name" \
    "$@"
