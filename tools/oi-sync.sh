#!/bin/bash
# oi-sync.sh -- copy this repo's oi-userland-style components (packages/)
# into the oi-userland checkout on an OpenIndiana build machine, so they build with
# OI's own make-rules.  Runs on your workstation, over ssh.
#
#   packages/<category>/<name>/  ->  ~/src/oi-userland/components/<category>/<name>/
#
# Only directories that hold a Makefile are copied, each with --delete
# inside its own directory; the rest of the oi-userland tree is never
# touched.  Build trees and downloads on the VM side are kept.
#
# Usage:  tools/oi-sync.sh [component-path ...]   (default: all)
#         OI_HOST=user@oi-build OI_USERLAND=src/oi-userland tools/oi-sync.sh
set -e
HOST="${OI_HOST:?set OI_HOST to the build machine, user@host}"
DEST="${OI_USERLAND:-src/oi-userland}"
TOP="$(cd "$(dirname "$0")/.." && pwd)"
E="ssh ${OI_SSH_OPTS:--o BatchMode=yes}"

cd "$TOP/packages"
if [ $# -gt 0 ]; then
	comps=("$@")
else
	mapfile -t comps < <(find . -name Makefile -not -path '*/patches/*' \
		-printf '%h\n' | sed 's|^\./||' | sort)
fi
[ ${#comps[@]} -gt 0 ] || { echo "oi-sync.sh: no components in packages/"; exit 0; }

$E "$HOST" "test -f $DEST/make-rules/shared-macros.mk" ||
	{ echo "oi-sync.sh: no oi-userland checkout at $HOST:$DEST" >&2; exit 1; }

# pkglint (userland.manifest1001) refuses dependencies on packages from
# publishers other than OI's.  Our components depend on each other through
# the local publisher oi-gnome (e.g. polkit -> library/duktape), so allow it
# in the checkout's tools/pkglintrc (the make-rules hard-code that path).
# Idempotent; the only local change to the oi-userland tree.
$E "$HOST" "cd $DEST/tools && grep -q '^userland.manifest.allowed_pubs = .* oi-gnome' pkglintrc ||
	sed -i 's/^\(userland.manifest.allowed_pubs = .*\)\$/\1 oi-gnome/' pkglintrc"

for c in "${comps[@]}"; do
	c="${c#packages/}"; c="${c%/}"
	[ -f "$c/Makefile" ] || { echo "oi-sync.sh: $c: no Makefile" >&2; exit 1; }
	$E "$HOST" "mkdir -p $DEST/components/$c"
	# 'P /*/': top-level directories that exist only on the VM (the sources
	# "gmake prep" unpacked: gcc-2.7.2.3/, binutils-2.8.1/, ...) are never
	# deleted; without it a re-sync removed them and pkgdepend, which reads
	# the source directory, failed at publish.  Our own directories
	# (patches/, files/) are still synced exactly.
	rsync -a --delete --filter 'P /*/' \
		--exclude '/build' --exclude '/*.log' --exclude '/*.tar.*' \
		--exclude '/*.zip' --exclude '/*.tgz' --exclude '/*.mog.*' \
		-e "$E" "$c/" "$HOST:$DEST/components/$c/"
	echo "oi-sync.sh: $c"
done
echo "oi-sync.sh: $(git -C "$TOP" rev-parse --short HEAD)$(git -C "$TOP" diff --quiet -- packages || echo +dirty) -> $HOST:$DEST"
