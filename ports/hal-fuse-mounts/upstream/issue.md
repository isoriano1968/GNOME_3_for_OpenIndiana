# illumos-gate issue (draft, to be filed by the user)

**Project:** illumos gate · **Tracker:** Bug · **Category:** cmd - hal ·
**Subject:**

    hal: storage tools treat FUSE mounts (ntfs-3g) as not mounted

## Description

A removable volume mounted through FUSE (ntfs-3g for NTFS, exfat-fuse for
exFAT) cannot be unmounted through HAL, and HAL mounts it a second time
when asked again:

- `org.freedesktop.Hal.Device.Volume.Unmount` fails with
  `NotMounted: According to HAL, the volume is not mounted`, so the
  desktop's eject button (gvfs HAL volume monitor) does nothing.
- `Mount` on an already mounted NTFS volume mounts it again (seen on an
  iMac13,2, OpenIndiana 2026.10: rmvolmgr restarted while the volume was
  mounted produced a second, read-write mount of the same partition).

### Cause

hald sets `volume.is_mounted` in devinfo_storage_mnttab_event()
(hald/solaris/devinfo_storage.c) by matching the mnttab entry's device
number (`mnt_major`/`mnt_minor`) with the volume's `block.major`/
`block.minor`. A FUSE mount carries the FUSE device's number, not the
disk's, so the volume stays "not mounted". hal-storage-mount and
hal-storage-unmount (tools/) trust that property.

### Fix

In the tools, also look for the volume's device file in mnttab
(`mnt_special`), via a small `device_in_mnttab()` in hal-storage-shared.c:
Mount refuses an already mounted device, Unmount accepts a mounted one,
and Unmount skips stale /media/.hal-mtab entries whose mount point is no
longer mounted. This needs the FUSE file system to record the /dev/dsk
name in mnttab: ntfs-3g canonicalizes it to the /devices path, which
OpenIndiana's ntfsprogs patches (separate, OpenIndiana-side).

A fuller fix would teach devinfo_storage_mnttab_event() to match by
`mnt_special` as well, so `volume.is_mounted` itself becomes right (and
rmvolmgr and the desktop see the state); that is a change to hald itself
and is left for review to decide.
