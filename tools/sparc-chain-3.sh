#!/bin/sh
# sparc-chain-3.sh -- runs ON the SPARC build host: build, publish and install
# a chain of components in the given order, each after the one before it is
# installed (the next one usually needs it to build).
#
#   sparc-chain.sh [-j N] category/name ...
#
# Each component: "gmake publish" (build, install, pkglint, publish) into the
# local repository $REPO as publisher oi-local-sparc, then "pkg install" of
# every package the component published, from that publisher.  A component
# whose last chain run finished (stamp .chain-done, removed by a new sync of
# its recipe) is skipped, so a chain can be rerun after a failure.  Several
# chains can run at the same time; pkg operations wait for each other.
#
# The tree is the one tools/u45-build.sh syncs (U45_TREE); gcc as there.
# Log of a component: <component>/publish.log.  Prints one line per step.
JOBS=64
while getopts j: o; do
	case $o in j) JOBS=$OPTARG ;; *) exit 2 ;; esac
done
shift $((OPTIND - 1))
TREE="$HOME/${U45_TREE:-gnome3-sparc/oi-userland}"
REPO="${SPARC_REPO:-$HOME/oi-local-sparc-repo}"
GCC="GCC_VERSION=${SPARC_GCC:-13}"

# Several chains build at the same time; their pkg operations on the image
# take turns through one lock (a directory, mkdir is atomic), so no two pkg
# clients collide and none waits inside pkg.
LOCK="${SPARC_PKG_LOCK:-$HOME/gnome3-sparc/pkg.lock}"
lock() { while ! mkdir "$LOCK" 2>/dev/null; do sleep 10; done; echo $$ > "$LOCK/pid"; }
unlock() { rm -rf "$LOCK"; }

pkg_retry() {	# pkg allows one operation per image at a time
	tries=0
	while :; do
		out=$(pfexec pkg "$@" 2>&1); rc=$?
		case "$out" in
		*"is locked"*|*"already in progress"*|*"in use by another"*) tries=$((tries + 1)); [ $tries -lt 120 ] || break; sleep 15 ;;
		*) break ;;
		esac
	done
	[ $rc -ne 0 ] && [ $rc -ne 4 ] && printf '%s\n' "$out" | tail -5
	return $rc
}

for c in "$@"; do
	d="$TREE/components/$c"
	[ -f "$d/Makefile" ] || { echo "FAIL $c: no recipe in $d"; exit 1; }
	[ -f "$d/.chain-done" ] && { echo "skip $c (done)"; continue; }
	cd "$d" || exit 1
	echo "build $c (JOBS=$JOBS) $(date '+%H:%M')"
	if ! nice -n 19 gmake $GCC JOBS=$JOBS WS_REPO="$REPO" PUBLISHER=oi-local-sparc \
	    publish > publish.log 2>&1 < /dev/null; then
		echo "FAIL $c: see $d/publish.log"
		grep -E '\*\*\*|[Ee]rror' publish.log | tail -5
		exit 1
	fi
	# the FMRI of every package the component published (pkgfmt wraps the
	# "set name=pkg.fmri" action, so continuation lines are joined first)
	f=$(cat build/manifest-*.published 2>/dev/null |
	    awk '/\\$/ { sub(/\\$/, ""); printf "%s", $0; next } { print }' |
	    sed -n 's/^set name=pkg.fmri *value=pkg:\/\([^@]*\)@.*/pkg:\/\/oi-local-sparc\/\1/p' | sort -u)
	[ -n "$f" ] || { echo "FAIL $c: no published manifest"; exit 1; }
	# A local package that supersedes a version the incorporation locks needs
	# that package's version-lock facet off, as on the x86 machines (only in
	# this image, i.e. the build boot environment); every facet set is logged.
	lock
	locks=$(pkg contents -m consolidation/userland/userland-incorporation 2>/dev/null |
	    sed -n 's/.*facet\.version-lock\.\([^=]*\)=true.*/\1/p')
	for p in $f; do
		n=${p#pkg://oi-local-sparc/}
		if printf '%s\n' $locks | grep -qx "$n"; then
			pkg_retry change-facet "facet.version-lock.$n=false" &&
			    echo "facet version-lock.$n=false (incorporation pins $n)"
		fi
	done
	pkg_retry install --accept $f; rc=$?
	unlock
	if [ $rc -ne 0 ] && [ $rc -ne 4 ]; then
		echo "FAIL $c: pkg install rc=$rc ($f)"
		exit 1
	fi
	touch .chain-done
	echo "done $c $(date '+%H:%M'): $(echo $f | sed 's|pkg://oi-local-sparc/||g')"
done
