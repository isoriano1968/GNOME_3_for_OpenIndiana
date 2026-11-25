#!/usr/bin/bash
#
# dtrace-neutral.sh: /usr/sbin/dtrace for package builds.  `dtrace -G` puts
# the build host's struct utsname into the object it writes (the DOF
# UTSNAME section), and with it the host name.  After a -G run this wrapper
# overwrites the nodename field with "localhost"; sysname, release, version
# and machine stay.  Every other dtrace call is passed through unchanged.
#
# Use: configure's DTRACE (e.g. CONFIGURE_ENV += DTRACE=$(WS_TOOLS)/dtrace-neutral).
# oi-sync.sh installs it as tools/dtrace-neutral in the oi-userland trees.

/usr/sbin/dtrace "$@" || exit $?

gen=0 out=
while [ $# -gt 0 ]; do
	case $1 in
	-G) gen=1 ;;
	-o) shift; out=$1 ;;
	-o*) out=${1#-o} ;;
	esac
	shift
done
[ $gen = 1 ] && [ -n "$out" ] && [ -f "$out" ] || exit 0

exec /usr/bin/python3 -I - "$out" "$(uname -s)" "$(uname -n)" <<'EOF'
import sys
path, sysname, node = sys.argv[1], sys.argv[2].encode(), sys.argv[3].encode()
F = 257                                 # SYS_NMLN: each utsname field
d = bytearray(open(path, 'rb').read())
n = 0
i = d.find(sysname + b'\0')
while i >= 0:
    f = d[i + F:i + 2 * F]
    if len(f) == F and f.startswith(node + b'\0'):
        d[i + F:i + 2 * F] = b'localhost'.ljust(F, b'\0')
        n += 1
    i = d.find(sysname + b'\0', i + 1)
if n:
    open(path, 'wb').write(d)
print('dtrace-neutral: %s: %d utsname nodename(s) neutral' % (path, n),
      file=sys.stderr)
EOF
