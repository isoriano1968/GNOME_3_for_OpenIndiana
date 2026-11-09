# Testing

## Built

- Against illumos-gate master b1c424a261 (2026-11-08); the three files are
  unchanged since long before 08e59b676b (the iMac's illumos).
- **Not a gate build.** hal-storage-mount and hal-storage-unmount compiled
  out of tree, 32-bit, on an OpenIndiana 2026.10 VM, as the package
  system/hal/storage-fuse (packages/sysutils/hal-storage-fuse), with
  Makefile.hal's defines; linked -ldbus-1 -lglib-2.0 -lhal -lhal-storage
  -lbsm -lpolkit.
- `cstyle -cpP` (b1c424a261 cstyle.pl): no new complaints; the files are
  third-party HAL code with many existing ones (GNU style).
- Still to do before an RTI: nightly build, `git pbchk`.

## Tested (iMac13,2, OI 2026.10, BE gnome45-audiohd)

See ../../hal-gpt-volumes/upstream/testing.md for the setup
(HALD_RUNNER_PATH=/usr/lib/hal/oi). Results are filled in below.

| What | Result |
|---|---|
| before: Unmount as the console user, ntfs-3g mount by HAL | NotMounted error |
| after: Unmount as the console user, `gio mount -u` (what the eject button does) | **OK**, exit 0, unmounted (2026-11-09 15:30) |
| after: Mount as the user (D-Bus Volume.Mount) | **OK**, mounted at /media/<label> |
| after: Mount on a mounted volume | **refused**: `AlreadyMounted: Device /dev/dsk/c5t0d0s1 is already mounted` |
| stale /media/.hal-mtab lines (left by unmounts done outside HAL) | skipped by Unmount; still in the file |
| `gio mount -d /dev/dsk/c5t0d0s1` as the user | **hangs** (timeout after 60 s); not yet looked into (gvfs HAL monitor mount path) |
| non-FUSE volume (pcfs stick) unmount, unchanged | not yet done |
