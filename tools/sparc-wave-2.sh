#!/bin/sh
# sparc-wave-2.sh -- runs ON the SPARC build host, inside the build boot
# environment's chroot: one "wave" of independent components with as few pkg
# operations on the image as possible (pkg, not the compiler, is the slow
# part on a many-core SPARC):
#   1. ONE pkg install of the external build dependencies (REQUIRED_PACKAGES
#      of all components that are not installed and not built in this wave);
#   2. all components build in parallel ("gmake install" into their proto
#      areas, -j per component), no pkg operation in between;
#   3. all publish (pkglint, pkgsend) to the local repository;
#   4. ONE pkg install of everything published, with the version-lock facets
#      (one change-facet) the incorporation needs for packages it pins.
#
#   sparc-wave-2.sh JOBS category/name ...
#
# JOBS: oi-userland builds configure/cmake components in parallel only with
# USE_PARALLEL_BUILD=yes and PARALLEL_JOBS (JOBS is not used); both are given
# on the gmake command line, the recipes stay as they are.  meson/ninja
# components are parallel anyway.
#
# Steps 1 and 4 take the pkg lock of sparc-chain-3.sh.  Logs per component
# (build.log, publish.log); one line per step on stdout.
J=$1; shift
TREE="$HOME/${U45_TREE:-gnome3-sparc/oi-userland}"
REPO="${SPARC_REPO:-$HOME/oi-local-sparc-repo}"
GCC="GCC_VERSION=${SPARC_GCC:-13}"
LOCK="${SPARC_PKG_LOCK:-$HOME/gnome3-sparc/pkg.lock}"
lock() { while ! mkdir "$LOCK" 2>/dev/null; do sleep 10; done; echo $$ > "$LOCK/pid"; }
unlock() { rm -rf "$LOCK"; }
W=$(mktemp -d /var/tmp/wave.XXXXXX)

# 1. external build dependencies, one install
own=""
for c in "$@"; do
	own="$own $(cd "$TREE/components/$c" && gmake -s $GCC print-value-COMPONENT_FMRI 2>/dev/null)"
	(cd "$TREE/components/$c" && gmake -s $GCC print-value-REQUIRED_PACKAGES 2>/dev/null) | tr ' ' '\n'
done | sed -e '/^$/d' -e '/\$/d' | sort -u > $W/req
printf '%s\n' $own | sort -u > $W/own
pkg list -H $(cat $W/req) 2>/dev/null | awk '{print $1}' | sort -u > $W/have
comm -23 $W/req $W/have | comm -23 - $W/own > $W/missing
if [ -s $W/missing ]; then
	echo "deps $(date +%H:%M): $(tr '\n' ' ' < $W/missing)"
	lock; pfexec pkg install --accept $(cat $W/missing) > $W/deps.log 2>&1; rc=$?; unlock
	echo "deps install rc=$rc"; [ $rc -eq 0 ] || [ $rc -eq 4 ] || { tail -5 $W/deps.log; exit 1; }
fi

# 2. build all in parallel
echo "build $(date +%H:%M): $*"
for c in "$@"; do
	( cd "$TREE/components/$c" &&
	  if nice -n 19 gmake $GCC USE_PARALLEL_BUILD=yes PARALLEL_JOBS=$J install > build.log 2>&1 < /dev/null; then
		echo "built $c $(date +%H:%M)"
	  else
		echo "FAIL $c (build): $TREE/components/$c/build.log"
	  fi ) &
done
wait

# 3. publish all that built
pub=""
for c in "$@"; do
	cd "$TREE/components/$c" || continue
	ls build/*/.installed > /dev/null 2>&1 || continue
	if gmake $GCC USE_PARALLEL_BUILD=yes PARALLEL_JOBS=$J WS_REPO="$REPO" PUBLISHER=oi-local-sparc publish > publish.log 2>&1 < /dev/null; then
		echo "published $c $(date +%H:%M)"; pub="$pub $c"
	else
		echo "FAIL $c (publish): $TREE/components/$c/publish.log"
	fi
done

# 4. one install of everything published (facets first, one call)
f=""
for c in $pub; do
	f="$f $(cat "$TREE/components/$c"/build/manifest-*.published 2>/dev/null |
	    awk '/\\$/ { sub(/\\$/, ""); printf "%s", $0; next } { print }' |
	    sed -n 's/^set name=pkg.fmri *value=pkg:\/\([^@]*\)@.*/\1/p')"
done
f=$(printf '%s\n' $f | sort -u)
[ -n "$f" ] || { echo "nothing to install"; rm -rf $W; exit 0; }
lock
pkg contents -m consolidation/userland/userland-incorporation 2>/dev/null |
    sed -n 's/.*facet\.version-lock\.\([^=]*\)=true.*/\1/p' | sort -u > $W/locks
pkg facet -H 2>/dev/null | awk '$2 == "False" { print $1 }' | sed 's/^version-lock\.//' | sort -u > $W/off
F=""
for n in $(printf '%s\n' $f | comm -12 - $W/locks | comm -23 - $W/off); do
	F="$F facet.version-lock.$n=false"; echo "facet version-lock.$n=false (incorporation pins $n)"
done
[ -n "$F" ] && pfexec pkg change-facet $F > $W/facets.log 2>&1
pfexec pkg install --accept $(printf 'pkg://oi-local-sparc/%s\n' $f) > $W/install.log 2>&1; rc=$?
unlock
echo "done wave install rc=$rc $(date +%H:%M): $(echo $f)"
[ $rc -eq 0 ] || [ $rc -eq 4 ] || tail -8 $W/install.log
rm -rf $W
