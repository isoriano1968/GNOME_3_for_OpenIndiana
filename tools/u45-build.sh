#!/bin/bash
# u45-build.sh -- build one component of packages/ on the OI SPARC test box
# (Ultra 45), in a private oi-userland tree there.  Runs on the preparation
# machine.  The box is shared with a driver session that reboots it often,
# so every step is restartable: rerun the same command after a reboot and
# the build continues where it stopped (objects stay on disk; nothing goes
# to /tmp).
#
#   tools/u45-build.sh [-j N] [-s STEP] <category/name>
#
# Steps:
#   sync    oi-userland base (make-rules, tools, transforms, doc, top files
#           and .git, from $OI_BASE at a recorded upstream commit) and
#           packages/<category/name> -> <tree>/components/<category/name>;
#           build trees and downloads on the box are kept
#   deps    list the component's REQUIRED_PACKAGES missing on the box;
#           installs nothing (the booted BE is not ours)
#   build   (default: sync,deps,build) start "nice -n 19 gmake build" in the
#           background on the box if it is not running yet; log in
#           <component>/build.log
#   status  is it running, last log lines, done stamp
#   mounts  (only with U45_ROOT) lofs mounts that a build inside the mounted
#           boot environment needs: /dev, /devices, /proc, /system/contract,
#           /etc/mnttab, the home directory; idempotent
#
# With U45_ROOT (the mount point of a non-booted build boot environment, e.g.
# from "beadm mount gnome3 /a/gnome3") deps asks "pkg -R U45_ROOT" and build
# runs in "chroot U45_ROOT" as the login user, so the build sees that boot
# environment's libraries and headers, not the booted one's.  mounts runs
# first then (default steps mounts,sync,deps,build).
#
# Build order of the GNOME 3 components: tools/gnome3-sparc.order.
# gcc: OpenIndiana SPARC's newest is gcc 13, so every gmake call gets
# GCC_VERSION=$SPARC_GCC (default 13) on the command line; the recipes stay
# unchanged for x86.
#
# Environment: U45_HOST (ssh host of the SPARC box, required), SPARC_GCC, OI_BASE (sparse clone of
# oi-userland with make-rules/tools/transforms, default ~/src/oi-userland-
# sparc-gnome), U45_TREE (default gnome3-sparc/oi-userland, in the home
# directory on the box).
set -e
JOBS=2
STEPS=sync,deps,build
ROOT="${U45_ROOT:-}"
[ -n "$ROOT" ] && STEPS=mounts,sync,deps,build
while getopts j:s: o; do
	case $o in j) JOBS=$OPTARG ;; s) STEPS=$OPTARG ;; *) exit 2 ;; esac
done
shift $((OPTIND - 1))
[ $# -eq 1 ] || { echo "usage: $0 [-j N] [-s steps] category/name" >&2; exit 2; }
c="${1#packages/}"; c="${c%/}"
HOST="${U45_HOST:?set U45_HOST to the ssh host of the SPARC box}"
BASE="${OI_BASE:-$HOME/src/oi-userland-sparc-gnome}"
TREE="${U45_TREE:-gnome3-sparc/oi-userland}"
GCC="GCC_VERSION=${SPARC_GCC:-13}"
TOP="$(cd "$(dirname "$0")/.." && pwd)"
E="ssh -o BatchMode=yes -o ConnectTimeout=10 -o ServerAliveInterval=30 $HOST"
has() { case ",$STEPS," in *",$1,"*) return 0 ;; esac; return 1; }
[ -f "$TOP/packages/$c/Makefile" ] || { echo "u45-build.sh: no packages/$c" >&2; exit 1; }

# run a shell command in the build environment: the booted system, or the
# chroot of $ROOT as the login user (the home directory is lofs-mounted there)
if [ -n "$ROOT" ]; then
	PKG="pkg -R $ROOT"
	IN() { printf '%s\n' "cd && $1" |
		$E "pfexec /usr/sbin/chroot $ROOT /usr/bin/su \$(id -un) -c '/bin/sh -s'"; }
else
	PKG=pkg
	IN() { $E "$1"; }
fi

if has mounts && [ -n "$ROOT" ]; then
	# /var/run/opengl: ogl-select fills it at boot (GL/gl.h links there); a
	# boot environment that is not booted needs the running system's
	$E "for m in /dev /dev/fd /devices /proc /system/contract /etc/mnttab /var/run/opengl \$HOME; do
		mount -p | awk '{print \$3}' | grep -qx $ROOT\$m && continue
		case \$m in
		/proc) pfexec mount -F proc proc $ROOT/proc ;;
		/dev/fd) pfexec mount -F fd fd $ROOT/dev/fd ;;
		/system/contract) pfexec mount -F ctfs ctfs $ROOT/system/contract ;;
		/etc/mnttab) pfexec mount -F mntfs mnttab $ROOT/etc/mnttab ;;
		/var/run/opengl) pfexec mkdir -p $ROOT\$m && pfexec mount -F lofs -o ro \$m $ROOT\$m ;;
		*) pfexec mkdir -p $ROOT\$m && pfexec mount -F lofs \$m $ROOT\$m ;;
		esac || exit 1
	done; echo 'mounts ready in $ROOT'"
fi

if has sync; then
	[ -f "$BASE/make-rules/shared-macros.mk" ] ||
		{ echo "u45-build.sh: no oi-userland base at $BASE" >&2; exit 1; }
	$E "mkdir -p $TREE/components/$c"
	rsync -a --delete -e "ssh -o BatchMode=yes" \
		--include='/make-rules/***' --include='/tools/***' \
		--include='/transforms/***' --include='/doc/***' --include='/.git/***' \
		--include='/Makefile' --include='/LICENSE' --exclude='*' \
		"$BASE/" "$HOST:$TREE/"
	# P /*/: keep the unpacked source tree(s) on the box (pkgdepend reads
	# the source directory as a proto directory), only the recipe is synced
	rsync -a --delete -e "ssh -o BatchMode=yes" --filter='P /*/' \
		--exclude='/build/' --exclude='/build.log' --exclude='/build.pid' --exclude='/*.tar.*' \
		--exclude='/.prep' --exclude='/.unpacked' --exclude='/firefox-*' \
		"$TOP/packages/$c/" "$HOST:$TREE/components/$c/"
	# pkglint (userland.manifest1001) refuses dependencies on packages from
	# publishers it does not know; ours depend on each other, so the local
	# publisher is allowed in this tree's tools/pkglintrc (as tools/oi-sync.sh
	# does for oi-local on x86)
	$E "cd $TREE/tools && grep '^userland.manifest.allowed_pubs = ' pkglintrc | grep -qw oi-local-sparc ||
		sed -i 's/^\(userland.manifest.allowed_pubs = .*\)\$/\1 oi-local-sparc/' pkglintrc"
	echo "synced $c (oi-userland base $(git -C "$BASE" log -1 --format=%h))"
fi

if has deps; then
	$E "cd $TREE/components/$c && L=\$(gmake -s $GCC print-value-REQUIRED_PACKAGES 2>/dev/null); M=''
		for p in \$L; do $PKG list -H \$p >/dev/null 2>&1 || M=\"\$M \$p\"; done
		if [ -n \"\$M\" ]; then echo \"missing on the box:\$M\"; exit 3; fi; echo 'build deps: all installed'" ||
		{ [ $? = 3 ] && has build && { echo "u45-build.sh: not building with missing deps" >&2; exit 3; }; }
fi

if has build; then
	IN "cd $TREE/components/$c && if [ -f build.pid ] && ps -p \$(cat build.pid) >/dev/null 2>&1; then
			echo 'build already running'
		else
			nohup nice -n 19 gmake $GCC USE_PARALLEL_BUILD=yes PARALLEL_JOBS=$JOBS build >> build.log 2>&1 < /dev/null &
			echo \$! > build.pid
			echo \"build started (pid \$!), log: ~/$TREE/components/$c/build.log\"
		fi"
fi

if has status; then
	$E "cd $TREE/components/$c && { [ -f build.pid ] && ps -p \$(cat build.pid) >/dev/null 2>&1 && echo running || echo 'not running'; }
		ls build/*/.built 2>/dev/null && echo 'built: yes'; tail -5 build.log 2>/dev/null | cut -c1-200"
fi
