#!/usr/bin/bash
#
# oi-manifest-gate.sh: the publish gate of oi-userland on the build VM.
# make-rules/ips.mk (tools/oi-userland-neutral-paths.patch) runs it on
# every package right before pkgsend; tools/oi-sync.sh installs it as
# tools/oi-manifest-gate in the checkout.  It publishes nothing itself.
#
#   oi-manifest-gate.sh REPO MANIFEST PROTO_DIR...
#
# 1. Refuses when REPO already has the manifest's pkg.fmri version (a changed
#    build gets a new revision, never the same version with a new
#    timestamp).
# 2. Refuses when the manifest text, or any file it delivers (looked up in
#    the PROTO_DIRs as pkgsend does), contains the build host's home
#    directory, /export/home/, the login name or the host name, or one of
#    the extra names in ~/.config/oi-gate-names (one grep -E pattern per
#    line, e.g. the other machines' host names; kept out of git).
#
# OI_GATE_SKIP (environment): an extended regular expression of delivered
# paths not to scan, for stock text that names /export/home in examples
# (osnet's man pages); the manifest itself is always scanned.
#
# Exit 0 = may publish, 1 = refused, 2 = usage.
#
# Copyright 2026 isoriano1968. CDDL-1.0.
set -u
[ $# -ge 3 ] || { sed -n 3,19p "$0"; exit 2; }
repo=$1 man=$2; shift 2

fmri=$(sed -n 's/^set name=pkg.fmri value=\([^ ]*\).*/\1/p' "$man" | head -1)
[ -n "$fmri" ] || { echo "oi-manifest-gate: no pkg.fmri in $man"; exit 2; }
f=${fmri#pkg:}		# drop the scheme and a publisher
case $f in //*) f=${f#//}; f=${f#*/} ;; /*) f=${f#/} ;; esac
name=${f%%@*} ver=${f#*@}; ver=${ver%%:*}; ver=${ver/,5.11/}
if pkgrepo list -H -s "$repo" "$name@$ver" >/dev/null 2>&1; then
	echo "REFUSED: $name@$ver is already in $repo:"
	pkgrepo list -H -s "$repo" "$name@$ver"
	echo "Bump COMPONENT_REVISION (or the version) and rebuild."
	exit 1
fi

user=$(id -un) host=$(hostname)
pat="$HOME|/export/home/|/home/$user\\b|\\b$user\\b|\\b$host\\b"
extra=$HOME/.config/oi-gate-names
[ -s "$extra" ] && pat="$pat|$(grep -v '^#' "$extra" | grep . | paste -sd'|' -)"

bad=0
if ggrep -n -E "$pat" "$man" >/dev/null; then
	echo "REFUSED: $name: the manifest names the build host:"
	ggrep -o -E ".{0,30}($pat).{0,30}" "$man" | sort -u | head -5
	bad=1
fi
# delivered files: "file SRC path=..." or "file NOHASH path=..." (source =
# path, looked up in the proto dirs in order).  OI_GATE_SKIP matches the
# delivered path, also where the source is a hash (republished stock files).
nawk '$1 == "file" {
	src = $2; p = ""
	for (i = 2; i <= NF; i++) if ($i ~ /^path=/) p = substr($i, 6)
	if (src == "NOHASH" || src ~ /=/) src = p
	print src, p }' "$man" | sort -u | while read -r src path; do
	[ -n "${OI_GATE_SKIP:-}" ] && echo "$path" | ggrep -q -E "$OI_GATE_SKIP" &&
	    continue
	for d in "$@"; do
		[ -f "$d/$src" ] || continue
		if ggrep -a -q -E "$pat" "$d/$src"; then
			printf 'REFUSED: %s: %s: ' "$name" "$src"
			ggrep -a -o -E "($pat)[^[:space:][:cntrl:]\"]{0,40}" \
			    "$d/$src" | sort -u | head -2 | tr '\n' ' '
			echo
			exit 1
		fi
		break
	done || exit 1
done || bad=1
[ $bad -eq 0 ] || exit 1
echo "oi-manifest-gate: $name@$ver ok (new version, no build-host names)"
exit 0
