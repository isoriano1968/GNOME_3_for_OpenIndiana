#!/bin/bash
# sparc-xvfb-shot.sh -- run X programs on a private Xvfb inside a mounted
# build boot environment on the SPARC build host and take a screenshot.
# Runs on the preparation machine; nothing appears on any real screen.
#
#   tools/sparc-xvfb-shot.sh [-d N] [-w SECS] [-g WxH] OUT.png 'cmd1' ['cmd2' ...]
#
# Each cmd is started in the background, in order, 3 s apart, on display :N
# (default 7) in "chroot $U45_ROOT" as the login user; after -w seconds
# (default 20) the root window is dumped with xwd, everything started here
# (by recorded pid) is stopped, and the dump is converted to OUT.png here
# (tools/xwd2png.py).  Program output: OUT.png.log.
#
# Environment: U45_HOST (ssh host, required), U45_ROOT (mount point of the
# build boot environment, default /a/gnome-build).
set -e
D=7 W=20 G=1600x1000
while getopts d:w:g: o; do
	case $o in d) D=$OPTARG ;; w) W=$OPTARG ;; g) G=$OPTARG ;; *) exit 2 ;; esac
done
shift $((OPTIND - 1))
[ $# -ge 2 ] || { echo "usage: $0 [-d N] [-w secs] [-g WxH] out.png cmd ..." >&2; exit 2; }
OUT=$1; shift
HOST="${U45_HOST:?set U45_HOST to the ssh host of the SPARC build machine}"
ROOT="${U45_ROOT:-/a/gnome-build}"
T=/var/tmp/xvfb-shot.$$

# the remote script: Xvfb, the programs, xwd, cleanup by pid
{
	echo "export DISPLAY=:$D LANG=C.UTF-8 NO_AT_BRIDGE=1"
	echo "mkdir -p $T && cd $T || exit 1"
	# a boot environment that never booted has no compiled GSettings schemas
	# (the desktop-cache service compiles them at boot): compile a private
	# copy, the boot environment itself stays untouched
	echo "mkdir -p schemas && glib-compile-schemas --targetdir=schemas /usr/share/glib-2.0/schemas && export GSETTINGS_SCHEMA_DIR=$T/schemas"
	# the same for the gdk-pixbuf loaders cache (icons, SVG theme assets)
	echo "gdk-pixbuf-query-loaders > loaders.cache 2>/dev/null && export GDK_PIXBUF_MODULE_FILE=$T/loaders.cache"
	echo "Xvfb :$D -screen 0 ${G}x24 -nolisten tcp > xvfb.log 2>&1 & echo \$! > pids"
	echo "sleep 3"
	for c in "$@"; do
		printf '%s\n' "( $c ) >> run.log 2>&1 & echo \$! >> pids; sleep 3"
	done
	echo "sleep $W"
	echo "xwd -root -silent > shot.xwd; echo xwd=\$?"
	echo "for p in \$(sort -r pids); do kill \$p 2>/dev/null; done; sleep 1"
	echo "for p in \$(cat pids); do kill -9 \$p 2>/dev/null; done"
} > "$OUT.remote.sh"
ssh -o BatchMode=yes "$HOST" "cat > $ROOT$T.sh" < "$OUT.remote.sh"
rm -f "$OUT.remote.sh"
ssh -n -o BatchMode=yes "$HOST" \
	"pfexec /usr/sbin/chroot $ROOT /usr/bin/su \$(id -un) -c '/bin/sh $T.sh'; rm -f $ROOT$T.sh"
scp -q "$HOST:$ROOT$T/shot.xwd" "$OUT.xwd"
ssh -n -o BatchMode=yes "$HOST" "cat $ROOT$T/run.log $ROOT$T/xvfb.log 2>/dev/null; rm -rf $ROOT$T" > "$OUT.log"
python3 -I "$(dirname "$0")/xwd2png.py" "$OUT.xwd" "$OUT" && rm -f "$OUT.xwd"
echo "log: $OUT.log"
