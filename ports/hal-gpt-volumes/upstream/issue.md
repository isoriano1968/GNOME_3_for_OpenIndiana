# illumos-gate issue (draft, to be filed by the user)

**Project:** illumos gate · **Tracker:** Bug · **Category:** cmd - hal
(or desktop) · **Subject:**

    hal: GPT partitions of removable disks never become volumes

## Description

A USB disk with a GPT (EFI) label is never mounted by rmvolmgr and never
shown by the desktop, whatever its file system: HAL creates the storage
device but no volumes for its partitions. USB drives formatted by Windows
(GPT: "Microsoft reserved" + NTFS or exFAT) or macOS, and large FAT32
sticks with GPT, are affected. MBR (fdisk) and VTOC disks work.

Seen on an iMac13,2 running OpenIndiana 2026.10 (illumos-08e59b676b) with
a 4 TB USB 3 drive (scsa2usb, sd), GPT with two
partitions. `lshal` shows for the disk

    storage.partitioning_scheme = 'gpt'
    storage.solaris.vtoc_slices = false
    storage.hotpluggable = true

and no child volumes.

### Cause

hald-probe-storage (usr/src/cmd/hal/probing/storage/probe-storage.c)
recognizes the GPT label (`efi_alloc_and_read()`, `scheme = "gpt"`) but
sets `storage.solaris.vtoc_slices` only for VTOC labels.
devinfo_volume_preprobing_done() (hald/solaris/devinfo_storage.c) then
skips every slice but the whole disk:

    /* if no VTOC slices found, don't probe slices except s2 */

On a GPT disk the partitions are the slices s0..s6, so none of them is
probed. hald-probe-volume itself reads GPT partitions fine (it has its own
`efi_alloc_and_read()` path), it is just never run for them.

A policy fdi that merges `storage.solaris.vtoc_slices=true` does not help:
HAL adds the volumes of a hotpluggable disk in a storage rescan, and every
rescan runs hald-probe-storage again and resets the property without
re-merging fdi files (devinfo_storage_rescan_probing_done()).

### Fix

Set `vtoc_slices = TRUE` in the GPT branch of probe-storage.c. Nothing else
is needed: devinfo_storage_minors() already adds volumes for the s0..s15
minor nodes of an EFI-labelled disk.
