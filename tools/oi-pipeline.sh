#!/bin/bash
# oi-pipeline.sh -- build, package, publish and install components of the
# GNOME port on an OpenIndiana build machine, one after another.  Runs on your workstation, over ssh.
#
#   tools/oi-pipeline.sh [-j N] [-s STEPS] <category/name> ...
#
# Steps (default "build,manifest,publish,install"):
#   build     tools/oi-sync.sh, then "gmake install" (ninja/make limited to
#             -j N, default 16; memory is checked first)
#   manifest  "gmake sample-manifest" without rebuilding (-o <src>/.prep;
#             checked with gmake -n first: an up-to-date ninja run is fine, a
#             re-unpack or reconfigure is refused), then, only if the component has
#             no .p5m / license file in packages/ yet, a draft made with
#             tools/sample-to-p5m.py and the upstream COPYING, copied back
#             into packages/ for review
#   publish   "gmake publish" to ~/oi-repo, publisher oi-gnome
#   install   "sudo -n pkg install" of the component's FMRI
#
# Stops at the first failure and prints the log lines that matter.
# Background: docs/gnome3-port.md (sections 4, 5)
# (the oi-userland rebuild trap: any goal through "install" re-unpacks).
set -e
JOBS=16
STEPS=build,manifest,publish,install
while getopts j:s: o; do
	case $o in j) JOBS=$OPTARG ;; s) STEPS=$OPTARG ;; *) exit 2 ;; esac
done
shift $((OPTIND - 1))
[ $# -gt 0 ] || { echo "usage: $0 [-j N] [-s steps] category/name ..." >&2; exit 2; }

HOST="${OI_HOST:?set OI_HOST to the build machine, user@host}"
TOP="$(cd "$(dirname "$0")/.." && pwd)"
E="ssh ${OI_SSH_OPTS:--o BatchMode=yes} -o ServerAliveInterval=30 $HOST"
CDIR=src/oi-userland/components
REPO="${OI_REPO:-\$HOME/oi-repo}"   # on the build machine
has() { case ",$STEPS," in *",$1,"*) return 0 ;; esac; return 1; }

"$TOP/tools/oi-sync.sh" "$@" >/dev/null
scp -q ${OI_SSH_OPTS:--o BatchMode=yes} \
	"$TOP/tools/sample-to-p5m.py" "$HOST:src/sample-to-p5m.py"

for c in "$@"; do
	c="${c#packages/}"; c="${c%/}"; name=$(basename "$c")
	echo "=== $c"
	if has build; then
		# available = free lists + ZFS ARC (the kernel shrinks the ARC on
		# demand); refuse below 6 GB (the 2026-11-08 hang: 32 GB anon)
		$E "echo ::memstat | sudo -n mdb -k 2>/dev/null | awk '/^ZFS File Data|^Free \\(/ { mb += \$(NF-1) } END { if (mb < 6144) { print \"oi-pipeline: only \" mb \" MB available, not building\"; exit 1 } }'"
		# install REQUIRED_PACKAGES that are missing (gmake prep would try
		# pfexec, which a plain user lacks); our own oi-gnome ones are skipped
		$E "cd $CDIR/$c && L=\$(gmake -s print-value-REQUIRED_PACKAGES 2>/dev/null); M=''; for p in \$L; do pkg list -H \$p >/dev/null 2>&1 || M=\"\$M \$p\"; done; if [ -n \"\$M\" ]; then echo \"  installing build deps:\$M\"; sudo -n pkg install \$M >/dev/null 2>&1; r=\$?; [ \$r = 0 ] || [ \$r = 4 ] || echo \"  (pkg install returned \$r)\"; fi"
		# make-rules/ninja.mk runs $(NINJA) -C dir: give it the job limit
		$E "cd $CDIR/$c && gmake 'NINJA=/usr/bin/ninja -j$JOBS' install > build.log 2>&1" || {
			$E "cd $CDIR/$c && /usr/gnu/bin/grep -n -A4 '^FAILED\| error: \|ERROR\|pkg install returned\|Hunk .*FAILED\|not found, tried\|CMake Error' build.log | cut -c1-240 | head -40"
			echo "oi-pipeline: $c: build failed (log: ~/$CDIR/$c/build.log)"; exit 1; }
		echo "  built"
	fi
	if has manifest; then
		$E "cd $CDIR/$c && src=\$PWD/\$(ls -d */.prep | head -1); o=\"-o \$src -o \$(dirname \$src)/.unpacked\" &&
			n=\$(gmake -n \$o sample-manifest 2>/dev/null | /usr/gnu/bin/grep -c 'meson setup\|userland-unpack\|cmake -G\|/configure ' || true) &&
			if [ \$n != 0 ]; then echo '  sample-manifest would rebuild, skipped'; exit 1; fi &&
			gmake \$o sample-manifest > sm.log 2>&1" || { echo "oi-pipeline: $c: sample-manifest failed"; exit 1; }
		lic=$(sed -n 's/^COMPONENT_LICENSE_FILE=[[:space:]]*//p' "$TOP/packages/$c/Makefile" | sed "s/\$(COMPONENT_NAME)/$(sed -n 's/^COMPONENT_NAME=[[:space:]]*//p' "$TOP/packages/$c/Makefile")/")
		p5m=$(ls "$TOP/packages/$c"/*.p5m 2>/dev/null | head -1)
		if [ -z "$p5m" ]; then
			$E "cd $CDIR/$c && python3 -I ~/src/sample-to-p5m.py manifests/sample-manifest.p5m $name.p5m --note 'Generated with gmake sample-manifest (tools/oi-pipeline.sh).'"
			$E "cat $CDIR/$c/$name.p5m" > "$TOP/packages/$c/$name.p5m"
			echo "  drafted packages/$c/$name.p5m"
		fi
		if [ -n "$lic" ] && [ ! -s "$TOP/packages/$c/$lic" ]; then
			$E "cd $CDIR/$c && s=\$(ls -d */.prep | head -1 | xargs dirname) && for f in COPYING LICENSE COPYING.LIB COPYING.LGPL; do [ -f \$s/\$f ] && { printf -- '--- %s ---\n\n' \$f; cat \$s/\$f; echo; }; done; true" > "$TOP/packages/$c/$lic"
			[ -s "$TOP/packages/$c/$lic" ] && echo "  license packages/$c/$lic" || { rm -f "$TOP/packages/$c/$lic"; echo "oi-pipeline: $c: no license file found"; exit 1; }
		fi
		"$TOP/tools/oi-sync.sh" "$c" >/dev/null
	fi
	if has publish; then
		if ! $E "cd $CDIR/$c && gmake WS_REPO=$REPO PUBLISHER=oi-gnome publish > pub.log 2>&1" &&
		   $E "/usr/gnu/bin/grep -q 'unresolved dependency' $CDIR/$c/pub.log"; then
			add=$("$TOP/tools/oi-deps.sh" "$c" | grep "^REQUIRED_PACKAGES" || true)
			if [ -n "$add" ]; then
				echo "$add" | while read -r l; do grep -qxF "$l" "$TOP/packages/$c/Makefile" || echo "$l" >> "$TOP/packages/$c/Makefile"; done
				echo "  added $(echo "$add" | wc -l) REQUIRED_PACKAGES from pkgdepend, retrying"
				"$TOP/tools/oi-sync.sh" "$c" >/dev/null
			fi
		fi
		$E "cd $CDIR/$c && { [ -f build/.published-i386 ] || gmake WS_REPO=$REPO PUBLISHER=oi-gnome publish > pub.log 2>&1; }" || {
			$E "cd $CDIR/$c && /usr/gnu/bin/grep -n -B2 -A6 '^ERROR\|unresolved dependency\|Error 1' pub.log | cut -c1-240 | tail -30"
			echo "oi-pipeline: $c: publish failed"; exit 1; }
		echo "  published"
	fi
	if has install; then
		fmri=$(sed -n 's/^COMPONENT_FMRI=[[:space:]]*//p' "$TOP/packages/$c/Makefile")
		ver=$(sed -n 's/^HUMAN_VERSION=[[:space:]]*//p; s/^COMPONENT_VERSION=[[:space:]]*//p' "$TOP/packages/$c/Makefile" | head -1)
		# explicit @version: OI's userland-incorporation pins old GNOME 2 names
		# at obsolete versions, and a bare name then silently does nothing;
		# pkg update picks up a republished build of the same version
		$E "sudo -n pkg refresh oi-gnome >/dev/null 2>&1; sudo -n pkg install $fmri@$ver > /dev/null 2>&1; r=\$?; [ \$r = 0 ] || [ \$r = 4 ] || exit 1; sudo -n pkg update $fmri@$ver > /dev/null 2>&1; r=\$?; [ \$r = 0 ] || [ \$r = 4 ]; pkg list -H $fmri@$ver >/dev/null 2>&1" ||
			{ echo "oi-pipeline: $c: pkg install $fmri@$ver failed (version-lock facet? see docs/gnome3-port.md)"; exit 1; }
		echo "  installed $fmri@$ver"
	fi
done
