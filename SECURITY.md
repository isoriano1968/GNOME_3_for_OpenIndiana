# Security notes

This page lists everything these packages add to or change on an
OpenIndiana system that has a bearing on security, so that you can check
it before you install anything. All file paths below are where the
packages install them. The recipes that produce each one are in
`packages/`.

## Supply chain

- **Upstream sources.**
  - Every component downloads one upstream release archive.
  - Its sha256 is fixed in the Makefile (`COMPONENT_ARCHIVE_HASH`).
  - oi-userland's `gmake` refuses an archive whose hash differs.
- **Changes to upstream.**
  - All changes are in `patches/`.
  - Each patch starts with a header:
    - patches taken from Solaris name their origin
      (`Origin: solaris-userland@9d7a655 ...`);
    - our own say "Not from Solaris" and explain why the change is needed.
  - No source file is replaced as a whole.
- **Own files, no upstream archive.** Three components:

  | Component | Content |
  |---|---|
  | `desktop/apple-media-keys` | a gsettings override (key bindings) |
  | `sysutils/fstyp-ntfs` | `fstyp-ntfs.c`, about 300 lines; it reads an NTFS boot sector and the `$Volume` record |
  | `sysutils/hal-removable-media` | a D-Bus policy, shown below |

- **No binaries.**
  - The repository holds no prebuilt packages.
  - You build as an ordinary user. Root is needed only for `pkg install`.
- **Packaging checks.**
  - The `.p5m` manifests list every file with owner and mode.
  - `pkglint` and `pkgdepend` check them during the build.

## Privileged programs

| File | Mode | From |
|---|---|---|
| `/usr/bin/pkexec` | 4555 root | polkit 125 (upstream) |
| `/usr/lib/polkit-1/polkit-agent-helper-1` | 4555 root | polkit 125 (upstream) |

No other file in these packages is setuid or setgid.

Installing these two files is the usual polkit installation. It is the
same on Solaris 11.4 and on Linux distributions.

## New users

| User | uid | Shell | Password | Purpose |
|---|---|---|---|---|
| `polkitd` | 63 | `/bin/false` | NP (none, cannot log in) | polkit authority daemon |
| `pulse` | 74 | `/bin/false` | none | PulseAudio system mode (not enabled by default) |

The user `gdm` (uid 50) already exists in OpenIndiana's base system
(SUNWcs).

## Services (SMF)

| Service | Runs as | Notes |
|---|---|---|
| `application/graphical-login/gdm` | root, as upstream gdm | installed **disabled**; you enable it in place of lightdm |
| `system/polkit` | starts as root, then switches to `polkitd` itself (as on Solaris) | enabled |
| `system/accountsservice` | root, as upstream | enabled; manages local accounts for Settings → Users |
| `colord` | `daemon` | colour profiles |
| `geoclue` | **root** | enabled. Upstream on Linux runs it as a dedicated `geoclue` user; we have not done that yet (known gap, see below). |

Packages that install a D-Bus policy refresh `svc:/system/dbus`
(`refresh_fmri`). Otherwise D-Bus would keep running with the old
policies.

## Login (gdm and PAM)

- **Where PAM is configured.** illumos reads PAM configuration only from
  `/etc/pam.conf`, and packages cannot add to that file. gdm therefore
  works with OpenIndiana's existing pam.conf.
- **User logins.** They go through the `gdm-password` service. pam.conf
  has no entry for that name, so its `other` entries apply: the normal
  `pam_unix` password check.
- **The login screen (greeter).** It runs as user `gdm`. Solaris gives it
  an allow-all stack through `user_attr pam_policy`; illumos has no
  `pam_policy`.
  - Patch `0030-illumos-greeter-pam.patch` therefore makes the greeter,
    and only the greeter, use OpenIndiana's existing `gdm-autologin`
    stack.
  - The patch does this with
    `strcmp (service, "gdm-launch-environment") == 0`.
  - Every other gdm PAM conversation keeps its own service name.
  - This is the same arrangement Solaris uses.
- **`0032-illumos-pam-tty.patch`.** It sets `PAM_TTY` for the session.
  illumos' `pam_unix_session` requires it for its utmpx/wtmpx records.
- **XDMCP** stays off, as upstream's default. The Solaris fix for the
  XDMCP buffer is applied.

## polkit and administrator rights

- **JavaScript engine.** polkit 125 is built with the duktape engine. It
  has no mozjs and needs no network.
- **Administrator identity.** polkit's rule is upstream's
  `unix-group:wheel`. OpenIndiana has no `wheel` group, so actions that
  require an administrator ask for **root's** password. Desktop users get
  no new rights through polkit.
- **accountsservice's "admin group" is `staff`** (`-Dadmin_group=staff`).
  - OpenIndiana puts every user in `staff`, so Settings → Users shows
    every user as "Administrator".
  - The label is cosmetic. It gives no root rights, because those come
    from RBAC profiles and sudo.
  - Setting a user to "Standard" there removes them from `staff`.
  - A different group is a one-line change in
    `packages/sysutils/accountsservice/Makefile`.

## Removable media

Mounting USB drives from the desktop uses HAL, rmvolmgr and gvfs, because
illumos has no udisks2. These changes are optional packages:

- **`system/hal/removable-media-policy`** installs
  `/etc/dbus-1/system.d/oi-hal-removable-media.conf`:

  ```xml
  <policy group="staff">
    <allow send_interface="org.freedesktop.Hal.Device.Volume"
           send_destination="org.freedesktop.Hal"/>
    <allow send_interface="org.freedesktop.Hal.Device.Storage"
           send_destination="org.freedesktop.Hal"/>
  </policy>
  ```

  - **Why it is needed.** HAL's own policy allows these calls only
    `at_console`, which is never true on OpenIndiana's dbus. As a result,
    only root could eject a drive.
  - **What still protects it.** HAL itself still checks the RBAC
    authorization `solaris.device.mount.removable` for every Mount,
    Unmount and Eject. Basic Solaris User already grants that
    authorization to every user, and it is what rmvolmgr relies on today.
- **`system/hal/probe-storage-gpt` and `system/hal/storage-fuse`**
  rebuild three HAL helpers from illumos-gate with one small patch each:
  - **GPT disks get volumes.** Before, HAL created none for removable
    GPT disks.
  - **FUSE mounts count as mounted.** HAL now matches a FUSE (ntfs-3g)
    mount by its device name.

  Details:
  - The helpers are installed under `/usr/lib/hal/oi`.
  - They take effect only after you set `HALD_RUNNER_PATH` on
    `svc:/system/hal`.
  - The same patches are prepared for illumos-gate in `ports/`.
- **`system/file-system/fstyp-ntfs`** lets libfstyp recognise NTFS. It
  only reads the filesystem.
- **NTFS volumes** are mounted by rmvolmgr under `/media/<label>`. They
  are read-write with `nosuid`.

## Security fixes carried as patches

| Component | Patch |
|---|---|
| gnome-shell 45.9 | `16-CVE-2024-36472.patch`, `17-CVE-2026-91786.patch` (+ validation follow-up) |
| evolution-data-server 3.50.3 | `06-CVE-2026-2604.patch` |
| polkit 125 | `09-CVE-2025-7519.patch` |
| accountsservice 0.6.55 | `0005-CVE-2012-6655.patch` |

Fixes from the Solaris tree that upstream already contains in our
versions were dropped. One example is polkit's CVE-2021-3560.

## Known limits

- **X11 only.** Any X client can read input sent to other clients and
  take screenshots. This is how MATE and every other X11 desktop on
  OpenIndiana work. Wayland is not available on illumos.
- **No screen lock hardening beyond upstream.** gnome-shell's lock screen
  is upstream's. gdm and ConsoleKit handle sessions; logind does not
  exist on illumos.
- **geoclue runs as root.** A dedicated unprivileged user is still to do.
  If you do not need location services, `svcadm disable geoclue`.
- **Screencast is disabled** at build time.
- **Some versions are older than GNOME's current release:** the session
  is GNOME 45, and the GTK 3 applications follow Solaris 11.4. We follow
  the Solaris and upstream security fixes for these versions, but this
  is a community port, not a vendor-supported release.

## Reporting a problem

Please use GitHub's **private vulnerability reporting** on this
repository (Security → Report a vulnerability) rather than a public
issue. For problems in upstream code, report to the upstream project as
well.
