# Eject / unmount of removable disks in GNOME 45 (OpenIndiana)

Follow-up to the removable-media work in docs/gnome3-port.md (commit
994b492: NTFS automount and eject from the desktop). Reported: a mounted
USB disk shows in the dock with its icon, but no eject button in the GNOME
menus. Investigated on the OI VM on 2026-11-10. The iMac did not answer, so the user's own session there was not
checked.

## Chain

HAL (illumos-gate, service/hal) → rmvolmgr mounts → gvfs 1.26.3 HAL volume
monitor (`gvfs-hal-volume-monitor`, the only native volume monitor; no
udisks2 on illumos) → GIO → gnome-shell / Dash to Dock / Nautilus.
Unmount goes back through gvfs: `gnome-mount -u -b -d <dev>` → HAL
Volume.Unmount → hal-storage-unmount.

## What gvfs reports for a USB hard disk

HAL marks a USB hard disk `storage.removable=false`,
`storage.requires_eject=false`, `storage.hotpluggable=true` (same for
lofi in devinfo_lofi_add_minor). gvfs's HAL monitor
(monitor/hal/ghaldrive.c `_do_update_from_hal`) sets the drive's
`can_eject` only for removable media that requires eject, and the volume
and mount take `can_eject` from the drive. `GHalMount::can_unmount` is
always TRUE. Measured with `gio mount -li` on the VM (fake HAL USB disk,
see Test below):

    Drive:  is_removable=0 can_eject=0
    Volume: can_mount=1 can_eject=0
    Mount:  can_unmount=1 can_eject=0

So every UI should offer **Unmount**, none **Eject**. (With udisks2 on
Linux, USB disks are "ejectable"/power-off and show Eject. That is a
different label, not a missing feature.)

## Each UI

| Place | Logic (source) | Result on the VM |
|---|---|---|
| Top bar | Plain GNOME Shell 45 shows removable drives nowhere in the top bar or system menu. The eject button there is the **Removable Drive Menu** extension (gnome-shell-extensions, `drive-menu@gnome-shell-extensions.gcampax.github.com`): shows a mount if `can_eject() \|\| can_unmount()`, and its eject button calls eject or unmount. | **Missing: the extension was not packaged.** This is the gap. |
| Dash to Dock 90 | locations.js: lists *volumes* only (a mount without a volume is not shown); menu actions `unmount` if `mount.can_unmount()`, `eject` if `mount.can_eject()`. | Menu shows **New Window / Unmount** (screenshot). |
| Nautilus 47.6 sidebar | gtkplacessidebar.c `check_unmount_and_eject`: eject icon if `can_eject` or `can_unmount`. | Eject icon next to the drive (screenshot). |

So if the disk is in the dock at all, its gvfs mount is tied to its HAL
volume and the dock menu has "Unmount" (labelled Unmount, not Eject).

## Fix: gnome-shell-extensions 45.2 as a component

`packages/desktop/gnome-shell-extensions` (pkg
`gnome/gnome-shell/extensions`): upstream tarball 45.2, meson,
`-Dextension_set=default` (drive-menu, places-menu, apps-menu,
window-list, ...), no classic session. Manifest from `gmake
sample-manifest`, REQUIRED_PACKAGES from `gmake REQUIRED_PACKAGES`.
`files/20_gnome-shell-extensions.gschema.override` enables drive-menu next
to Dash to Dock. It has to repeat dash-to-dock: `enabled-extensions` is also
set by 10_dash-to-dock.gschema.override, and the later file wins.

Tested in a private gnome-shell (Xvfb :57, its own HOME, XDG dirs and D-Bus
session bus) with the built extension loaded from the private HOME: the
eject icon appears in the top bar, the menu lists the volume with an eject
button and "Open Files", and the button runs gvfs's unmount
(gnome-mount).

## Other findings

- **The VM lacks the 994b492 packages** (removable-media-policy,
  storage-fuse, probe-storage-gpt, fstyp-ntfs; ntfsprogs is OI's
  2022.10.3). Without `system/hal/removable-media-policy` the system bus
  refuses HAL Volume.Unmount to the user: the eject button ends in
  gnome-mount's "Cannot unmount volume: org.freedesktop.DBus.Error.AccessDenied".
  The iMac has the policy installed (docs/gnome3-port.md), and `gio mount -u`
  worked there.
- **VM dconf has `/org/gnome/shell/disable-user-extensions=true`** for the
  user (set earlier, by an unknown session). GNOME 45 then loads no
  extensions except the session mode's, *including system-wide ones*
  (Dash to Dock, Removable Drive Menu). Reset it with
  `gsettings reset org.gnome.shell disable-user-extensions`, or the Extensions
  app's main switch, if the VM session should show them.
- **lofi disks never reach HAL on current illumos.** HAL's
  devinfo_lofi_add_major expects one lofi instance with one minor per
  device ("lofi always has one instance"). Since lofi was changed, each
  device is its own instance (`/pseudo/lofi@1`), so no HAL storage or
  volume appears for `lofiadm -a`. That is an illumos-gate HAL bug, not filed.
- **Symbolic icons:** gvfs's HAL volume/mount give
  `folder-remote-symbolic` as the symbolic icon, so Nautilus' sidebar
  shows a network-folder icon for a USB disk (the dock's full-colour icon is
  right). Cosmetic, gvfs-hal; not fixed.
- Test trap: under `dbus-run-session`, `gsettings set` goes through the
  D-Bus-activated dconf-service, which gets the *bus's* environment. Set
  HOME/XDG_CONFIG_HOME before starting the bus, otherwise the write lands
  in the real ~/.config/dconf/user. (Happened once at 11:30; the one key
  was reset with `dconf reset /org/gnome/shell/enabled-extensions`.)

## Test method (VM, no window on the user's display)

1. `mkfile 64m`, `lofiadm -a`, `mkfs -F pcfs` on the lofi device.
2. Fake USB disk in HAL (lofi is invisible to HAL): `hal-device --add`
   with a storage device (`storage.bus=usb`, `removable=false`,
   `hotpluggable=true`, `block.device=/dev/lofi/1`, capabilities
   `{'storage', 'block'}`) and a volume (`volume.fstype=pcfs`,
   `block.storage_device` = the storage udi, capabilities
   `{'volume', 'block'}`). Lists need lshal syntax `{'a', 'b'}`, otherwise
   `info.capabilities` is silently dropped and gvfs ignores the device.
3. `mount -F pcfs /dev/lofi/1 /media/EJECTTEST` as root (as rmvolmgr does).
4. Private session: Xvfb :57, HOME/XDG_* under the test dir, then
   `dbus-run-session -- gnome-shell --x11 --sm-disable`; clicks with a
   small ctypes XTest script (no xdotool on OI); screenshots with
   `xwd -root | convert`. The shell's overview repaints badly on Xvfb;
   Nautilus is easier to capture on a second Xvfb without a compositor.
5. Cleanup: umount, `hal-device --remove`, `lofiadm -d`, kill own pids.

## Installed on the VM and tested end to end (2026-11-10 12:18, user OK)

- `gnome/gnome-shell/extensions@45.2` published to oi-gnome and installed
  (tools/oi-pipeline.sh -s publish,install). The system default
  `enabled-extensions` is now `['dash-to-dock@…', 'drive-menu@…']`.
- `system/hal/removable-media-policy` (oi-gnome, from 994b492) installed;
  pkg refreshed svc:/system/dbus.
- Test: fake HAL USB disk as above, mounted through HAL Volume.Mount *as
  the user* (works with the policy), private gnome-shell with no settings
  of its own. The top bar shows the eject icon; its menu lists the volume;
  the eject button unmounted it (mnttab entry and /media/EJECTTEST gone,
  `volume.is_mounted=false`), and the drive left the top bar and the dock.
- The fake volume needs `block.major`/`block.minor` (here 130/64 for
  /dev/lofi/1). hald sets `volume.is_mounted` by matching mnttab's `dev=`
  to them; without them HAL refuses Unmount with "not mounted". For FUSE
  (NTFS) mounts, where `dev=` doesn't match either, that is what
  `system/hal/storage-fuse` handles (not installed on the VM).

## Still to do

- Install `gnome/gnome-shell/extensions` on the iMac (p5p or the repo, as
  for the other oi-gnome packages) and try the top-bar eject with the real
  NTFS disk there.
- On the VM, `disable-user-extensions=true` in the user's dconf still turns
  all extensions off in a real session there (see above).
- Whether "Eject" (rather than "Unmount") is wanted for USB hard disks:
  that would need a gvfs-hal patch making hotpluggable drives ejectable,
  plus an eject path that works for non-removable USB disks on illumos.
