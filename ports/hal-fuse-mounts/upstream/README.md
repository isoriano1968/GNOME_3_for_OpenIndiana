# hal: FUSE mounts seen as mounted by the storage tools (upstream submission, prepared, not submitted)

Everything here is local; filing and uploading are the user's steps.

| File | What |
|---|---|
| `0001-NNNNN-hal-storage-tools-treat-FUSE-mounts-ntfs-3g-as.patch` | the change, `git format-patch` against illumos-gate master b1c424a261; author isoriano1968, no trailers |
| `issue.md` | text for the illumos-gate issue |
| `testing.md` | what was built and tested |

Commit message (illumos format, one line, no body):
`NNNNN hal: storage tools treat FUSE mounts (ntfs-3g) as not mounted`.
The submission steps are the same as in ../../hal-gpt-volumes/upstream/README.md.

Local use: the same patch is in packages/sysutils/hal-storage-fuse/patches/,
which builds system/hal/storage-fuse (oi-gnome):
/usr/lib/hal/oi/hal-storage-{mount,unmount}, used through the same
HALD_RUNNER_PATH=/usr/lib/hal/oi as system/hal/probe-storage-gpt. It
replaces no file of service/hal; going back is `pkg uninstall
system/hal/storage-fuse`. It needs ntfsprogs 2026.9.28 revision 1
(oi-gnome), which records /dev/dsk names in mnttab.
