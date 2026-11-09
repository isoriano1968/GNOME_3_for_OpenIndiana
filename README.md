# GNOME 3 (GNOME Shell 45) for OpenIndiana

The GNOME Shell 45 desktop with gdm, and the usual GNOME applications, for
OpenIndiana Hipster. Every piece is an IPS package built from an
**oi-userland component**: the pristine upstream release (pinned by
sha256), a `patches/` directory, a package manifest (`.p5m`) and a license
file. Nothing is copied onto the system by hand. You install it with
`pkg`, into a new boot environment, and you go back with one `beadm`
command.

It runs on real hardware: an iMac13,2 (NVIDIA GTX 675MX, NVIDIA 470
driver) under OpenIndiana 2026.10. It also runs in VirtualBox, using software GL.

- [What you get](#what-you-get)
- [How it was done](#how-it-was-done)
- [Build and install](#build-and-install)
- [Security](#security), with details in [SECURITY.md](SECURITY.md)
- [Layout of this repository](#layout-of-this-repository)
- [The 2024 attempt](#the-2024-attempt)

## What you get

| Layer | Components |
|---|---|
| Session | gnome-shell 45.9, mutter 45.7 (X11), gnome-session 45.0, gnome-settings-daemon 45.1, **gdm 45.0.1** as the login screen, gnome-control-center 41.7, Dash to Dock 90 |
| Services | polkit 125 (duktape JS engine), accountsservice 0.6.55, colord 1.4.7, geoclue 2.7.2, evolution-data-server 3.50.3, PulseAudio 17.0 |
| Libraries | libgweather 4.4.4, geocode-glib 3.26.4, gsound 1.0.3, gnome-autoar 0.4.5, colord-gtk 0.3.1, duktape 2.7.0, libportal 0.11.0, libspelling 0.4.11, tinysparql 3.8.2, Cantarell 0.301 |
| Applications | Files (nautilus 47.6), Terminal 3.60.0, Text Editor 47.4, Calculator 47.3, Disk Usage Analyzer 47.0, File Roller 44.7, Image Viewer (eog 45.4), Document Viewer (evince 48.4), System Monitor 42.0, Screenshot 41.0, GNOME backgrounds 47.0 |
| Removable drives | NTFS and other USB drives mount automatically under `/media/<label>`, and the user can eject them from the desktop. This uses HAL, rmvolmgr and gvfs, because illumos has no udisks2. It needs four small packages (see below). |
| Hardware | volume, mute and media keys work through PulseAudio. Apple keyboards get a gsettings override for Super+F7..F12. |

Not included:
- **Wayland.** The desktop is X11 only.
- **systemd and logind.** ConsoleKit takes their place.
- **udisks2, NetworkManager, Bluetooth panels and GNOME Online Accounts.**
- **localsearch**, the file indexer. Search in Files still works without it.

## How it was done

1. **The source is Oracle's solaris-userland.** Solaris 11.4 already ships
   GNOME Shell 45 on X11 with ConsoleKit, which is the same situation as
   on illumos. Its component Makefiles, build options and patches
   were the starting point. Each Solaris patch we took has a header that
   names its origin (`Origin: solaris-userland@9d7a655 ...`). Patches
   that only apply to Solaris were dropped. For example, these are gone:
   - the CDE dtlogin handoff;
   - `libv12n`;
   - the SPARC patches;
   - security fixes that the newer upstream releases already contain.
2. **The packages use oi-userland's own build system.** Each component in
   `packages/<category>/<name>/` is copied into an oi-userland checkout
   (`tools/oi-sync.sh`) and built with OpenIndiana's make-rules. They
   could therefore go into oi-userland unchanged.
3. **Applications use newer releases where OpenIndiana allows it.**
   OpenIndiana already has GTK 4.16 and libadwaita 1.6, so the GTK 4
   applications are taken straight from their GNOME 47 releases.
   Examples are Files, Text Editor, Calculator and Disk Usage Analyzer.
   The GTK 3 applications follow Solaris' versions.
4. **Some patches are written for illumos itself.** Each one says
   "Not from Solaris" in its header and explains the reason. The main
   ones:
   - **gdm:** login screen PAM, the ConsoleKit path, and PAM_TTY without
     logind (`0030`–`0032`).
   - **accountsservice:** wtmpx, and the `noaccess` user.
   - **PulseAudio:** finds every OSS device and exposes names, ports and
     volume (`30`, `31`).
   - **ntfsprogs:** writes the device to mnttab the way gvfs expects.
   - **HAL:** two fixes that are also prepared for illumos-gate (`ports/`).
     - **GPT disks:** HAL never created volumes for removable GPT disks.
     - **FUSE mounts:** HAL did not recognise FUSE (ntfs-3g) mounts as
       mounted.
   - **Smaller build fixes:** terminal exit codes, tinysparql winsize,
     libportal memfd.
5. **Every package is checked by the build.** It is built,
   `pkgdepend`-resolved and `pkglint`-checked, then published to a local
   IPS repository (publisher `oi-gnome`). It is installed on a test
   machine into a new boot environment and tested there:
   - **first in a VM** (VirtualBox, VBoxSVGA);
   - **then on real hardware.**

The full engineering log is [docs/gnome3-port.md](docs/gnome3-port.md):
- the survey of Solaris against OpenIndiana;
- the build order;
- every decision, trap and fix, with dates.

## Build and install

At the moment there is no public package server. You build the packages
yourself on an OpenIndiana machine and install them from your own local
repository. This takes about one afternoon on a fast machine.

**1. Prepare an OpenIndiana build machine** (Hipster 2026.10 or later):

```bash
pfexec pkg install build-essential
git clone https://github.com/OpenIndiana/oi-userland.git ~/src/oi-userland
pkgrepo create ~/oi-repo && pkgrepo add-publisher -s ~/oi-repo oi-gnome
```

**2. Copy the components in, then build and publish each one.** Follow
the order in [docs/gnome3-port.md](docs/gnome3-port.md), section 5:
libraries first, then the session, gdm last. Two ways:

- **On the build machine itself:**

  ```bash
  cp -r packages/<category>/<name> ~/src/oi-userland/components/<category>/
  cd ~/src/oi-userland/components/<category>/<name>
  gmake WS_REPO=$HOME/oi-repo PUBLISHER=oi-gnome publish
  ```

- **From another machine over ssh:**

  ```bash
  OI_HOST=user@oi-build tools/oi-pipeline.sh -s build,publish desktop/nautilus
  ```

  Optionally set `OI_SSH_OPTS` (for example `-i ~/.ssh/key`) and
  `OI_REPO`.

`gmake env-prep` in a component installs its build dependencies from
openindiana.org. `gmake` downloads each upstream archive and **refuses it unless its
sha256 matches** `COMPONENT_ARCHIVE_HASH` in the Makefile. Then it
applies `patches/` and builds as an ordinary user. Root is never used
for building.

**3. Install into a new boot environment**, so that your running system
stays as it is:

```bash
pfexec pkg set-publisher -g file://$HOME/oi-repo oi-gnome
pfexec beadm create gnome45 && pfexec beadm mount gnome45 /mnt
pfexec pkg -R /mnt install --no-backup-be \
    system/display-manager/gdm gnome/gnome-shell gnome/file-manager/nautilus \
    terminal/gnome-terminal editor/gnome-text-editor desktop/calculator/gnome-calculator
pfexec beadm umount gnome45 && pfexec beadm activate gnome45
```

A few packages replace older GNOME 2 builds that OpenIndiana's
incorporation locks: gdm 2.30, gnome-terminal, system-monitor and
ntfsprogs. They need their version-lock facet lifted first:

```bash
pfexec pkg -R /mnt change-facet facet.version-lock.<fmri>=false
```

Run it before the install, with the same `-R /mnt`. The log names each
package that needs this.

**4. Boot the new environment, then switch the login screen** from
lightdm to gdm. Until you do, lightdm offers a GNOME session next to
MATE:

```bash
pfexec svcadm disable lightdm
pfexec svcadm enable application/graphical-login/gdm
```

**To go back:** `pfexec beadm activate <previous BE>` and reboot. Nothing
in the old boot environment was changed.

**Optional, for removable drives:** install `system/hal/probe-storage-gpt`,
`system/file-system/fstyp-ntfs`, `system/hal/storage-fuse` and
`system/hal/removable-media-policy`. Then run:

```bash
pfexec svccfg -s system/hal setenv HALD_RUNNER_PATH /usr/lib/hal/oi
pfexec svcadm refresh system/hal
pfexec svcadm restart system/hal rmvolmgr
```

## Security

People reasonably ask what a desktop port changes on a system. In short:

- **The sources can be checked.** Every upstream archive is pinned by
  sha256, and every change is a readable patch with a header that gives
  its origin and reason. Only three components are our own files and
  have no upstream archive:
  - a gsettings override for the keys;
  - an NTFS `fstyp` module of about 300 lines of C;
  - a D-Bus policy.
- **The repository holds no binaries.** You build everything yourself
  from the recipes, so nothing here asks you to trust a prebuilt package.
- **There is no setuid code beyond upstream's.** Only polkit's
  `pkexec` and `polkit-agent-helper-1` are setuid root, exactly as in
  every Linux distribution and in Solaris.
- **New system accounts:** `polkitd` (uid 63) and `pulse` (uid 74). Both
  have login shell `/bin/false` and no password. `gdm` already exists
  in OpenIndiana.
- **Login still authenticates through PAM and `/etc/pam.conf`.** Only gdm's own greeter (user `gdm`, which draws
  the login screen) uses OpenIndiana's existing `gdm-autologin` stack. This
  is the same arrangement Solaris uses. User logins go through
  `gdm-password` and pam.conf's normal password checks.
- **Things that differ from a stock OpenIndiana install, and that you
  should know about:**
  - **accountsservice treats group `staff` as administrators.** On
    OpenIndiana every user is in `staff`, so every user shows as
    "Administrator" in Settings → Users. This label does not give anyone
    root. Rights still come from RBAC and sudo. It is one Makefile line
    to change.
  - **The removable-media D-Bus policy** lets group `staff` call HAL's
    Mount and Unmount methods, so the desktop's eject button works.
    HAL still checks the existing RBAC authorization
    `solaris.device.mount.removable` for each call.
  - **NTFS drives mount read-write with `nosuid`.**
- **Fixes carried as patches, where the release itself lacks them:**
  - **gnome-shell:** CVE-2024-36472 and CVE-2026-91786.
  - **evolution-data-server:** CVE-2026-2604.
  - **polkit:** CVE-2025-7519.
  - **accountsservice:** CVE-2012-6655.
- **X11's limits still apply.** Any X client can read input sent to other
  X clients, as with MATE on OpenIndiana today. Wayland is not available
  on illumos.

[SECURITY.md](SECURITY.md) has the complete inventory: privileged
programs, services, users, D-Bus policies and RBAC. It also explains how
to report a problem.

## Layout of this repository

| Folder | Content |
|---|---|
| `packages/desktop/` | gdm, gnome-shell, mutter, session, settings, control center, applications, PulseAudio, key settings |
| `packages/library/` | libraries that are not yet in OpenIndiana |
| `packages/sysutils/` | polkit, accountsservice, the HAL fixes, NTFS |
| `packages/fonts/` | Cantarell |
| `ports/` | the two HAL changes, prepared as illumos-gate patches with issue text and test notes |
| `tools/` | `oi-sync.sh` copies the components into an oi-userland checkout; `oi-pipeline.sh` builds, publishes and installs; `oi-deps.sh` and `sample-to-p5m.py` help write manifests; `new-meson-component.py` creates a skeleton for a new component |
| `docs/` | the engineering log |
| `legacy-2024/` | the 2024 dependency survey |

## The 2024 attempt

In February 2024 this repository held a dependency survey:
- the Solaris GNOME components' `REQUIRED_PACKAGES`, collected with awk;
- `gnome-dep-check.c`, which sorts them;
- a script that checked which of them OpenIndiana had.

Those files are now in `legacy-2024/`. Since then, OpenIndiana has gained
gtk4, libsoup-3, gcr-4, gjs, poppler and more. That left a shorter list of
components to write, and they are all here now.

## License

Each component is under its upstream license (see its `.license` file).
The build recipes follow oi-userland and solaris-userland (CDDL).
