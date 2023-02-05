#!/bin/bash

awk --help    >/dev/null || ( echo "missing dependency: awk"     >/dev/stderr && exit 1 )
sed --help    >/dev/null || ( echo "missing dependency: sed"     >/dev/stderr && exit 1 )
jq --help     >/dev/null || ( echo "missing dependency: jq"      >/dev/stderr && exit 1 )
xrandr --help >/dev/null || ( echo "missing dependency: xrandr"  >/dev/stderr && exit 1 )