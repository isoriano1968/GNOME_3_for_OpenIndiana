#!/bin/bash
# oi-deps.sh -- print REQUIRED_PACKAGES lines for the libraries pkgdepend could
# not resolve when a component's "gmake publish" failed ("unresolved
# dependency ... pkg.debug.depend.file=X").  Runs on your workstation, over ssh; looks the files
# up in an index of the VM's installed packages (path -> package), built once
# with "-r" (pkg search is slow on the VM: its search index is degraded).
#
#   tools/oi-deps.sh [-r] <category/name> ...
set -e
E="ssh ${OI_SSH_OPTS:--o BatchMode=yes} ${OI_HOST:?set OI_HOST to the build machine, user@host}"
if [ "$1" = -r ]; then
	shift
	$E 'pkg contents -H -o path,pkg.name -t file,link > ~/src/pkg-paths.new && mv ~/src/pkg-paths.new ~/src/pkg-paths.txt && wc -l ~/src/pkg-paths.txt'
fi
for c in "$@"; do
	c="${c#packages/}"; c="${c%/}"
	echo "# $c"
	$E "cd src/oi-userland/components/$c && for f in \$(/usr/gnu/bin/grep -o 'pkg.debug.depend.file=[^ ]*' pub.log | sed 's/.*=//' | sort -u); do
		p=\$(/usr/gnu/bin/grep -E \"^(usr/lib/amd64|lib/amd64|usr/lib/64|lib/64|usr/lib/mps/64|usr/lib/mps/amd64|usr/gnu/lib/amd64)/\$f[[:space:]]\" ~/src/pkg-paths.txt | awk '{print \$2}' | head -1)
		[ -n \"\$p\" ] && echo \"REQUIRED_PACKAGES += \$p\" || echo \"# unresolved: \$f\"
	done | sort -u"
done
