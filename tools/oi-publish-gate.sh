#!/usr/bin/bash
# oi-publish-gate.sh: checks to run on the build VM right before
# `gmake publish` of an oi-local package; it publishes nothing itself.
#
#   oi-publish-gate.sh REPO FMRI VERSION PROTO_DIR [ALLOWLIST]
#   e.g. oi-publish-gate.sh ~/oi-local-repo web/browser/chromium \
#            150.0.7871.186-2026.0.0.5 build/prototype/i386
#
# 1. Refuses when REPO already has FMRI@VERSION (a changed build gets a new
#    revision, never the same version with a new timestamp).
# 2. Refuses when a file under PROTO_DIR contains the build host's home
#    directory, the login name or the host name (builds must use neutral
#    paths or prefix maps). ALLOWLIST is an optional file of grep -E
#    patterns for lines that may stay (one per line).
# Exit 0 = may publish, 1 = refused, 2 = usage.
set -u
[ $# -ge 4 ] || { sed -n 2,15p "$0"; exit 2; }
repo=$1 fmri=$2 version=$3 proto=$4 allow=${5:-}

if pkgrepo list -H -s "$repo" "$fmri@$version" >/dev/null 2>&1; then
	echo "REFUSED: $fmri@$version already in $repo:"
	pkgrepo list -H -s "$repo" "$fmri@$version"
	echo "Bump COMPONENT_REVISION (or the version) and rebuild."
	exit 1
fi
echo "ok: $fmri@$version is not in $repo yet"

[ -d "$proto" ] || { echo "REFUSED: no proto dir $proto"; exit 1; }
user=$(id -un) host=$(hostname)
pat="$HOME|/export/home/|/home/$user\b|\b$user\b|\b$host\b"
hits=$(find "$proto" -type f -print0 |
	xargs -0 ggrep -a -l -E "$pat" 2>/dev/null | head -200)
if [ -n "$allow" ] && [ -n "$hits" ]; then
	keep=
	for f in $hits; do
		if ggrep -a -o -E ".{0,40}($pat).{0,40}" "$f" |
		    ggrep -v -E -f "$allow" | ggrep -q .; then
			keep="$keep $f"
		fi
	done
	hits=$keep
fi
if [ -n "$hits" ]; then
	echo "REFUSED: build-host paths or names in $(echo $hits | wc -w) file(s):"
	for f in $hits; do
		printf '  %s: ' "${f#$proto/}"
		ggrep -a -o -E "($pat)[^[:space:][:cntrl:]\"]{0,50}" "$f" | sort -u |
		    head -2 | tr '\n' ' '
		echo
	done | head -40
	exit 1
fi
echo "ok: no home path, login name or host name in $proto"
exit 0
