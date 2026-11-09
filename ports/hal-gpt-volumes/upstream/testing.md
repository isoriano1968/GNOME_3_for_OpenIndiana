# Testing (for the issue's "Testing Done" and the RTI)

## Built

- `0001-NNNNN-hal-...patch` is against illumos-gate master b1c424a261
  (2026-11-08). probe-storage.c has not changed since 2019 (last commit
  32248f1178), so it is the same in 08e59b676b, the iMac's illumos.
- **Not a gate build.** hald-probe-storage was compiled out of tree on an
  OpenIndiana 2026.10 VM, as the OI package system/hal/probe-storage-gpt
  (packages/sysutils/hal-probe-storage-gpt): probe-storage.c, utils/cdutils.c,
  utils/fsutils.c, hald/logger.c with Makefile.hal's HAL_CONFIG_CPPFLAGS,
  gcc 14, 64-bit (the gate builds it 32-bit), linked with -ldbus-1 -lhal
  -ladm -lefi. No warnings that matter (the gate's CERRWARN list was not
  used).
- `cstyle -cpP probe-storage.c` (illumos-gate b1c424a261 cstyle.pl):
  nothing new. The file is third-party HAL code and has 152 complaints
  before and after the change.
- **Still to do before the RTI:** a nightly build with the patch (clean
  mail_msg) and `git pbchk`.

## Tested (iMac13,2, OI 2026.10, illumos-08e59b676b, BE gnome45)

The patched prober was installed as /usr/lib/hal/oi/hald-probe-storage and
hald was started with HALD_RUNNER_PATH=/usr/lib/hal/oi (so the stock
/usr/lib/hal/hald-probe-storage stays in place).

| What | Result |
|---|---|
| stock prober: 4 TB USB 3 drive, GPT (s0 Microsoft reserved, s1 NTFS) | `vtoc_slices = false`, no volumes (2026-11-09) |
| fdi policy merging `vtoc_slices=true` | merged, then reset by the next rescan; no volumes |
| patched prober, `svcadm restart hal` | `vtoc_slices = true`; volumes s0..s15 added and probed (hald --verbose) |
| s1 (NTFS) | probed; identified once a libfstyp module for ntfs-3g was installed (OI's ntfsprogs ships only a shell script, a separate OpenIndiana issue); then `volume.fstype = 'ntfs-3g'`, label read, rmvolmgr mounted it at /media/<label> |
| s0 (Microsoft reserved, no file system) | probed, no file system, discarded as before |
| physical unplug / re-plug of the drive with the patched prober | **not yet done** |
| a GPT FAT32 stick (pcfs, no third-party module involved) | **not yet done**: the cleanest test for the illumos part alone |
| MBR and VTOC disks (should be unchanged) | **not yet done** |
