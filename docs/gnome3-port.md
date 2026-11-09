# GNOME 3 (Solaris 11.4's GNOME 45) on OpenIndiana: survey and plan

Status: **plan approved by the user (2026-11-08); step 0 (prep) done,
see section 5.** No builds yet. The decisions in section 6 are still
open.

Sources surveyed on 2026-11-08:

- solaris-userland (github.com/oracle/solaris-userland) at `9d7a655`
  (2026-11-08): `components/gnome/` (97 components), `components/desktop/`
  (59) and the x11/python/perl/rust bits they need.
- oi-userland (github.com/OpenIndiana/oi-userland) at `2cadaa12`
  (2026-11-08).
- The OI VM (Hipster 2026.10). It went offline during the
  survey (the reboot for the MATE/dbus fix, presumably), so the installed
  package list is only partly checked (libdrm 2.4.109 and mesa 21.3.9 are
  installed). Step 0 below finishes that.

- The 2024 attempt in this repository (`legacy-2024/`, `c921177`):
  (`c921177`, Feb 2024, against Solaris 11.4.42 CBE). It has the same idea
  (solaris-userland's GNOME components on oi-userland's build system), but
  only the dependency survey: the `REQUIRED_PACKAGES` of the Solaris GNOME
  components collected with awk, `gnome-dep-check.c` to split them into
  system packages and GNOME-internal ones, and a script that checked and
  installed the system packages on OI. Its "not available on OI" list
  (2024) agrees with section 3a: polkit, accountsservice, colord(-gtk),
  geoclue, libgweather, evolution-data-server, mutter, gnome-session,
  gnome-settings-daemon, gdm, gnome-menus, gsound, gnome-autoar, eog,
  evince, nautilus, gedit, libdazzle, libgxps, exempi, mozjs-115/gjs, plus
  Solaris-only `libv12n` and `devinfo`. Since 2024 OI has gained gtk4,
  libsoup-3, gcr-4, gjs (1.90), gom, grilo, libmediaart, gtksourceview and
  poppler, which that list still had as missing. No component Makefiles
  or patches to reuse.

Versions come from each Makefile's `COMPONENT_VERSION` / `HUMAN_VERSION`;
the full table is in the appendix.

## 1. What Solaris 11.4 ships

Solaris ships the **GNOME Shell 45** stack, **X11 only**, with **ConsoleKit**
in place of systemd-logind. Some apps are newer and some much older. The core
pieces:

| Layer | Components (Solaris version) |
|---|---|
| Session core | gnome-shell 45.9, mutter 45.7, gnome-session 45.0, gnome-settings-daemon 45.1, gdm 45.0.1, gnome-shell-extensions 45.2, background-logo-extension 45.beta |
| Settings and UI | gnome-control-center **41.7** (GTK3 + libhandy), gnome-tweaks 45.1, dconf 0.40, dconf-editor 45.0.1, gsettings-desktop-schemas 45.0 |
| JS | gjs 1.78.5 on mozjs-115 (115.2.0); mozjs-140 is also there, for polkit/firefox |
| Toolkit | glib2 2.89.3, gobject-introspection 1.84, gtk3 3.24.51, gtk4 4.14.5, libadwaita 1.3.6, libhandy 1.8.2, pango 1.56.4, cairo 1.18.4, harfbuzz 12.3, gdk-pixbuf 2.44.8, librsvg 2.56.3, at-spi2-core 2.58.1, graphene 1.10.8, json-glib 1.8.0 |
| Services | polkit 125, accountsservice 0.6.55, ConsoleKit 0.4.1, upower 1.90.4, colord 1.4.7, geoclue 2.7.2, pulseaudio 14.2, dbus 1.16.0, ibus 1.5.29 |
| Data libs | evolution-data-server 3.50.3, libgweather 4.4.4, geocode-glib 3.26.4, libsoup-3 3.7.2, glib-networking 2.90.1, gcr 3.38 + gcr-4 4.1.0, gnome-keyring 46.2, libsecret 0.21.7, gnome-online-accounts 3.58.1 |
| Look | adwaita-icon-theme 41.0, cantarell-fonts 0.301, gnome-backgrounds 41.0, gnome-menus 3.36 |
| Apps | nautilus **3.34**, gnome-terminal 3.41 (vte 0.66), gedit 41, eog 45.2, evince 48.4, totem 43.1, gnome-calculator 41, gnome-clocks 44, gnome-calendar 41.2, gnome-screenshot 41, gnome-font-viewer 41, seahorse 47, orca 45.2, zenity 3.41, yelp tools, tracker 2.3.6 + tracker-miners 2.3.5 (for nautilus 3.34) |
| Graphics | Xorg, mesa 21.3.8 with llvmpipe (swrast + LLVM 13), libdrm 2.4.120, libepoxy 1.5.10 |
| Build | gcc 14, meson 1.12.1, ninja 1.12.1, Python 3.11 for gnome-shell's build scripts (3.13 also there), Perl 5.38/5.42, rust 1.96, nodejs 22/24 (not needed by GNOME) |

The Solaris build options that define this stack (from the Makefiles):

- mutter: `-Dwayland=false -Dxwayland=false -Dnative_backend=false
  -Dsystemd=false -Dudev=false -Dlibwacom=false -Dremote_desktop=false
  -Dprofiler=false`, plus patches that remove dma-buf (`08-disable-dma`,
  467 lines) and libei/EIS (`10-disable-eis`, 1225 lines).
- gnome-shell: `-Dnetworkmanager=false -Dportal_helper=false -Dsystemd=false
  -Dcamera_monitor=false`; `01-consolekit.patch` brings ConsoleKit support
  back into `loginManager.js` (upstream removed it). Screencast is
  disabled, and `15-revert-AdwToolbarView` exists only because their
  libadwaita is 1.3.
- gdm: `-Dsolaris=true -Dwayland-support=false -Dsystemd-journal=false
  -Dplymouth=disabled -Dinitial-vt=7 -Dxauth-dir=/tmp`, plus 29 patches.
  The big one is `0002-disable-systemd` (1319 lines). The rest cover
  Solaris PAM, SMF contracts, /etc/default/login, logindevperm, wtmpx, BSM
  audit, VT switching and xauth.
- gnome-session: `-Dsystemd=false -Dsystemd_session=disable
  -Dconsolekit=true`.
- gnome-settings-daemon: `-Dwayland=false -Dgudev=false
  -Dnetwork_manager=false -Drfkill=false -Dwwan=false -Dalsa=false
  -Dsystemd=false`.
- gnome-control-center 41: patches remove udisks, gudev, wwan, online
  accounts and libsoup, and adapt the user-accounts, timezone, datetime,
  power and printer panels.
- polkit 125: `-Dos_type=solaris -Dsession_tracking=ConsoleKit
  -Djs_engine=mozjs` (mozjs-115), with polkitd running as user `_polkitd`,
  uid 63.
- accountsservice: `-Dsystemd=false -Delogind=false -Dadmin_group=sysadmin
  -Dminimum_uid=100`.

## 2. What oi-userland already has

**Already packaged, and new enough (reuse as they are, 50-odd
components):** glib 2.86.5, gobject-introspection 1.86.0, gtk+3 3.24.52,
gtk4 4.16.13, pango 1.58.0, cairo 1.18.6, harfbuzz 15.1.0, gdk-pixbuf
2.44.8, librsvg 2.61.4, at-spi2-core 2.62.1, json-glib 1.10.6, graphene
1.10.8, libsoup3 3.6.4, glib-networking 2.80.1, libsecret 0.21.7, gcr 3.41.2
+ gcr-4 4.4.0.1, gnome-keyring 46.2, gnome-desktop 44.4,
gsettings-desktop-schemas 50.1, libadwaita 1.6.10, libhandy 1.8.3,
**gjs 1.90.1 on mozjs-140 140.17.0**, PyGObject 3.54.3, libnotify 0.8.9,
libcanberra 0.30, startup-notification 0.12, libxkbcommon 1.13.2,
xkeyboard-config 2.41, libepoxy 1.5.10, lcms2 2.20, **ConsoleKit 0.4.6**
(already carrying the Solaris patch set: ck-dynamic, vtdaemon, fastreboot,
multisession, etc.), upower 0.99.11, pulseaudio 17.0, dbus 1.16.2, ibus
1.5.29, libical 3.0.20, geocode-glib 3.26.4, gom 0.5.5, grilo 0.3.19,
libgtop 2.40.0, dconf 0.40.0, dconf-editor 45.0.1, adwaita-icon-theme 50.0,
gnome-themes-extra 3.28, zenity 3.44.5, yelp 49.2, yelp-tools,
gstreamer 1.28.9, vte-291 0.84.1, libpeas 1.20 + libpeas-2, gmime3 3.2.15,
libgsf, poppler 26.02, totem 42.0, seahorse 47.0.1, orca 47.3, gucharmap
18.0, sassc 3.6.2, meson 1.7.2, ninja 1.13.2, vala 0.56.19, cmake 4.4.5,
rust 1.99.0, cbindgen, Python 3.9/3.13/3.14, Perl 5.40/5.42, gcc 14
(default), clang 16–23.

**IPS names are free.** OI renamed its old GNOME 2 packages with a `-2`
suffix (`system/display-manager/gdm-2`, `gnome/gnome-session-2`,
`gnome/gnome-settings-daemon-2`), so the Solaris names (`gnome/gnome-shell`,
`gnome/window-manager/mutter`, `system/display-manager/gdm`,
`gnome/gnome-session`, `gnome/gnome-settings-daemon`,
`gnome/preferences/control-center`, `system/library/polkit`,
`system/library/accountsservice`, …) can be used. Step 0 checks that the
OI publisher has no obsolete or renamed history under those names.

## 3. Gaps, and what won't carry over

### 3a. Missing in OI (new components we write)

Needed for the session (tier 1–3 below):

| Component | Solaris ver | Needed by | Note |
|---|---|---|---|
| polkit | 125 | colord, g-s-d, gnome-shell (agent), g-c-c, gdm, accountsservice | **Not in OI at all.** Use `-Djs_engine=duktape` (a new small `library/duktape` component) instead of mozjs-115. `os_type`: illumos is close to Solaris, so the Solaris procfs/fdwalk patches likely apply as they are. |
| accountsservice | 0.6.55 | gdm, gnome-shell, g-c-c | Admin group `sysadmin` (Solaris) → `staff` or a new group on OI: to decide. |
| colord | 1.4.7 | **mutter 45** (color management), g-s-d, g-c-c | Needs a `colord` system user and a D-Bus system service. |
| colord-gtk | 0.3.1 | g-c-c | |
| geoclue | 2.7.2 | g-s-d (timezone), gnome-shell (location) | No ModemManager or avahi backends; needs a `geoclue` system user. |
| libgweather | 4.4.4 | g-s-d, gnome-shell, e-d-s, clocks | |
| evolution-data-server | 3.50.3 | gnome-shell (calendar server) | CMake build, no GOA, no WebKit. The biggest library build. |
| mutter | 45.7 | gnome-shell | Solaris options and patches as listed above. |
| gnome-shell | 45.9 | | |
| gnome-session | 45.0 | | |
| gnome-settings-daemon | 45.1 | | |
| gdm | 45.0.1 | | Last: lightdm keeps working until then (see 3c). |
| gnome-control-center | 41.7 | | GTK3 + libhandy, as in Solaris. |
| gnome-shell-extensions, background-logo-extension | 45.x | | |
| cantarell-fonts | 0.301 | shell default font | |
| gnome-backgrounds | 41.0 | | |
| gnome-menus | 3.36.0 | apps-menu extension, alacarte | |
| gsound | 1.0.3 | g-c-c, gnome-shell | |
| gnome-tweaks, mousetweaks | 45.1, 3.32 | | |

Apps (tier 4; optional, after a working session): nautilus 3.34 (needs
tracker 2.3.6 + tracker-miners 2.3.5; OI has only tracker 1.8.3, so this
would be a parallel `tracker-2`), gnome-autoar 0.4.5, gnome-terminal 3.41,
eog 45.2, evince 48.4, gedit 41, gnome-calculator, gnome-clocks,
gnome-calendar, gnome-screenshot, gnome-font-viewer, gnome-user-docs,
libgxps, libdazzle, exempi. There are 46 missing rows in all (appendix).

### 3b. Version differences to watch

- **gjs / mozjs.** Solaris uses gjs 1.78 + mozjs-115. OI has gjs 1.90 +
  mozjs-140. **Plan: build gnome-shell 45 against OI's gjs 1.90 first.**
  gnome-shell 45 is already all ES modules, and the libgjs C API it uses is
  stable. A private mozjs-115 + gjs-1.78 pair is only the fallback, since
  mozjs is the most expensive build in the stack (Firefox's SpiderMonkey:
  rust + clang + hours).
- **gsettings-desktop-schemas 50.1** (OI) vs 45.0. mutter, g-s-d and the
  shell 45 read keys that later releases may have moved or dropped. Check
  with `gsettings` at runtime. If anything breaks, patch the consumers;
  do not ship an older schemas package, because that would downgrade OI's.
- **libadwaita 1.6** (OI): drop Solaris' `15-revert-AdwToolbarView` patch.
- **adwaita-icon-theme 50** (OI) vs 41: shell 45 may ask for icons renamed
  since then. Small patches or a symlink list, if any.
- **upower 0.99.11** (OI) vs 1.90.4: g-s-d 45 and the shell work with
  upower-glib ≥ 0.99.8. Keep OI's and do not touch it. OI's upower is
  `system/upower`, and Solaris' power backend patches don't apply.
- **ConsoleKit 0.4.6** (OI) vs 0.4.1: reuse OI's, which has the Solaris
  patches already. Check that ck-list-sessions and the D-Bus API match what
  `01-consolekit.patch` (shell) and gnome-session expect.
- **meson 1.7.2** (OI) vs 1.12: enough for GNOME 45 (needs ≥ 0.60/1.1).
- **Python:** Solaris pins Python 3.11 for gnome-shell's build scripts. OI
  builds modules for 3.9 and 3.14. Use **3.14** (and the PyGObject variant
  for 3.14) wherever GNOME runs Python (gnome-tweaks, build scripts).
- **Perl:** used only at build time (itstool / intltool-style scripts):
  OI's 5.42 default.

### 3c. Solaris-specific bits that won't carry over as they are

- **Graphics stack.** Solaris' mesa uses llvmpipe (LLVM 13). OI's mesa
  21.3.9 is built with `-Dllvm=false`, so only **softpipe** is there:
  slow, but it gives GL 3.3, enough for mutter 45's cogl (GL ≥ 3.1).
  In VirtualBox there is no KMS/DRM driver on illumos, so the shell runs
  on software GL under Xorg 1.19.7 with xf86-video-vboxvideo/vmware. A
  usable shell probably needs llvmpipe, which means rebuilding OI's mesa
  with one of OI's clang/LLVM versions. **That is a change to an OI
  package, and is proposed separately** (option, not part of the base
  plan). The pending vboxsvga + 128 MB VRAM change helps here.
- **No Wayland, no systemd/logind, no udev.** As on Solaris: X11 session,
  ConsoleKit for seats and sessions, SMF instead of systemd units, and no
  gudev/libinput/libwacom/rfkill/NetworkManager/ModemManager/bluetooth. The
  Solaris meson options above are the template. OI's `wayland/freeway` is
  irrelevant.
- **gdm's Solaris patches** (29) assume Solaris facilities. Most also
  exist on illumos, because they come from OpenSolaris: PAM,
  `/etc/default/login`, `/etc/logindevperm`, wtmpx, BSM audit, SMF
  contracts (libcontract), VTs + vtdaemon. `0004-sdtlogin` (CDE dtlogin
  handoff) and the Solaris-only PAM message tweaks can be dropped. Expect
  to rework `0002-disable-systemd` against illumos and to test VT handling
  carefully. **gdm comes last.** Until then the GNOME session is started
  from the existing **lightdm** (a `gnome.desktop` / `gnome-xorg.desktop`
  xsession), so the MATE login keeps working the whole time.
- **SMF and services.** Solaris ships SMF manifests or D-Bus activation for
  gdm, polkitd, accountsservice, colord and geoclue. OI needs the same as
  SMF manifests plus new system users (`polkitd`, `colord`, `geoclue`,
  `gdm`) through IPS `user`/`group` actions. Each service needs its D-Bus
  policy file and a **`svcadm refresh dbus` after install**. Today's
  MATE outage came from exactly that (dbus never reloaded the new
  policies), so the packages should carry `refresh_fmri=svc:/system/dbus:default`
  on their `/etc/dbus-1` and `/usr/share/dbus-1/system.d` files.
- **gnome-control-center panels** that Solaris rewrote for Solaris tools
  (user accounts, datetime/timezone, printers, power, `libv12n`
  virtualization detection) need checking against illumos equivalents
  (`/etc/default/init` TZ, `zoneinfo`, cups, `svcadm`). `libv12n` is
  Solaris-only: drop that patch.
- **Branding and defaults:** `06-solaris-background`, favourite apps and
  the gdm logo are Solaris branding. Replace them with OpenIndiana defaults
  (or leave them upstream).
- **Licensing:** the Solaris Makefiles and manifests are CDDL (as
  oi-userland's), and their patches are against GPL/LGPL code under the
  upstream licenses. Each component gets the upstream `.license`. Each
  Solaris patch we take keeps its header and notes its origin
  (`solaris-userland@9d7a655`).
- **SPARC-only patches** (`*.sparc`) are skipped.

## 4. How the packages are built and published

- Components live in this repo under `packages/<category>/<name>/` in
  oi-userland layout: `Makefile` (oi-userland make-rules, pristine upstream
  tarball + sha256), `patches/`, `<name>.p5m`, `<name>.license`,
  `manifests/` (generated sample manifest), and an SMF manifest where
  needed. Categories follow oi-userland: `library/`, `desktop/gnome/`,
  `sysutils/`, `fonts/`.
- Builds run on the OI VM in a **user-owned oi-userland checkout**
  (`~/src/oi-userland`, at a recorded commit). A helper,
  `tools/oi-sync.sh`, rsyncs `packages/` into its `components/` tree, so
  our components use OI's make-rules unchanged and could be upstreamed as
  they are.
- Publishing goes to a **local file repository** on the VM
  (`~/oi-repo`, publisher `oi-gnome`) via `gmake publish`. Installing from
  it needs `pkg set-publisher -g file://… oi-gnome` (a system change: I'll
  ask first) and then `pkg install` (also asked first).
- Install the GNOME packages into a **new boot environment**
  (`beadm create gnome-test` + install there), so MATE in the current BE
  stays untouched and rollback is one `beadm activate`. That is a boot
  environment change: I'll ask first.

## 5. Build order

Each tier builds only after the previous one is published. The heavy step
(e-d-s, mutter, gnome-shell) waits until no other heavy build runs (one heavy build at a time on
the VM host).

0. **Prep (no builds). Done 2026-11-08:**
   - oi-userland `2cadaa12` is at `~/src/oi-userland` on the VM. The VM has
     **no git**, so the shallow clone was made on the workstation and rsynced over
     (the commit is in `.oi-userland-commit`).
   - Local repository `~/oi-repo` (publisher prefix `oi-gnome`, empty) was
     created with `pkgrepo create`. A build publishes there with
     `gmake WS_REPO=~/oi-repo PUBLISHER=oi-gnome publish`
     (pkgsend uses `WS_REPO`, not `PKG_REPO`). With the user's OK it was
     added as a system publisher on 2026-11-08
     (`pkg set-publisher -g file://~/oi-repo oi-gnome`,
     ranked after openindiana.org).
   - `tools/oi-sync.sh` copies `packages/<cat>/<name>/` into
     `~/src/oi-userland/components/<cat>/<name>/`, one component directory
     at a time, keeping build trees and downloads on the VM.
   - Installed and reusable: glib2 2.86.5, gtk3 3.24.52, gtk4 4.16.13,
     libadwaita 1.6.10, gobject-introspection 1.86.0, libsoup3 3.6.4,
     gnome-keyring 46.2, upower 0.99.11, xorg 1.19.7, ConsoleKit 0.4.6
     (FMRI `library/xdg/consolekit`), lightdm 1.30.0.
   - **Not installed (build dependencies to install before tier 1–3, from
     the openindiana.org publisher, asked first):** meson, ninja, rustc,
     gjs, mozjs-140, gnome-desktop, gsettings-desktop-schemas, gcr-4. The
     exact FMRIs are in the component Makefiles (`REQUIRED_PACKAGES`).
   - **FMRI check:** none of `gnome/gnome-shell`,
     `gnome/window-manager/mutter`, `system/library/polkit`,
     `system/library/accountsservice`, `service/image/colord`,
     `library/desktop/geoclue` or `library/duktape` exists in the
     openindiana.org catalog. These exist only as **obsolete** (`--o`)
     GNOME 2-era versions: `gnome/gnome-session` 2.32.1,
     `gnome/gnome-settings-daemon` 2.32.1,
     `gnome/preferences/control-center` 2.32.1,
     `system/display-manager/gdm` 2.30.7,
     `library/desktop/evolution-data-server` 3.24.0 and
     `library/desktop/libgweather` 3.24.1. Our versions are all higher, so
     IPS takes them as the successors and the names stay usable. For OI
     upstreaming later, the version bump un-obsoletes them, which is normal
     IPS practice.
   - **Found during the tier 1 dry run:** oi-userland's make-rules call
     `/usr/bin/git` (WS_TOP is the git root, and ips-buildinfo records the
     commit). Real builds therefore need `developer/versioning/git` on the
     VM, a build tool under decision 3. **Installed 2026-11-08** (git
     2.56.0, one package, no new BE). Both components now parse without a
     `WS_TOP` override. `gmake prep` installs missing packages with
     `pfexec pkg install`, which fails for the build user (no admin profile). So
     before each prep, install the component's `REQUIRED_PACKAGES` with
     `sudo -n pkg install` (named first). The workspace build set
     (`USERLAND_REQUIRED_PACKAGES`: build-essential, ruby, openjdk8, lzip)
     was installed by the toolchain session on 2026-11-08. Also, `gmake prep`
     runs `pkg install` of the component's `REQUIRED_PACKAGES` itself.
1. **Services:** `library/duktape` → `system/library/polkit` 125 →
   `system/library/accountsservice` 0.6.55 → `service/image/colord` 1.4.7
   → `library/desktop/colord-gtk` → `library/desktop/geoclue` 2.7.2.
   Each comes with an SMF manifest, users, D-Bus policy and a quick check
   with `pkexec`/`busctl`-like gdbus calls.
   **Written, not yet built (2026-11-08):**
   - `packages/library/duktape`: 2.7.0, upstream `Makefile.sharedlibrary`
     (justmake). 64-bit `libduktape.so.207.20700` linked with `-lm`, plus
     `duktape.pc` and the headers. The debug variant libduktaped is dropped.
     MIT.
   - `packages/sysutils/polkit`: 125, meson. Options:
     `-Djs_engine=duktape -Dsession_tracking=ConsoleKit -Dos_type=solaris
     -Dpolkitd_user=polkitd -Dpolkitd_uid=63` (uid 63 is free on the VM),
     introspection and man pages on, gtk-doc, examples and tests off.
     - Patches kept from Solaris, each marked with its origin: 00-solaris,
       01-procfs, 04-fdwalk, 06-manpage, 09-CVE-2025-7519 (not in 125) and
       gcc14 (renamed 10-gcc14-illumos-pam; illumos' PAM prototypes are
       Solaris').
     - Dropped: 07-CVE-2021-3560, already fixed in 125 (the old patch only
       applied with fuzz), and the SPARC mozjs patch.
     - Removed after install: systemd/sysusers/tmpfiles files, and
       `usr/lib/pam.d/polkit-1`. illumos has no /etc/pam.d, and the
       `other` entries in /etc/pam.conf cover the `polkit-1` service.
     - SMF `svc:/system/polkit` (`files/polkit.xml` + `svc-polkit`, after
       Solaris). The p5m (Solaris' file list without gtk-doc/examples) adds
       the `polkitd` user and `refresh_fmri=svc:/system/dbus:default` on
       the D-Bus policy file. OI has no dbus actuator, which is what broke
       the MATE login today.
     - All six patches apply cleanly to the pristine tarball, and
       `gmake -n prep` parses both components on the VM.
   - **Prep on the VM (2026-11-08, no builds):** `gmake prep` for duktape
     (download, hash check, unpack: ok). `gmake patch` for polkit: all six
     patches apply with offsets only, no fuzz. polkit's own `gmake prep`
     would try to install `library/duktape`, so it waits until duktape is
     published to `oi-gnome` and installed on the build VM.
   - **duktape built, published and installed (2026-11-08):** the build
     took about 1 min and pkglint passed. `library/duktape@2.7.0` is in
     `oi-gnome` and installed in the current BE (a build dependency, user
     approved). `libduktape.so.207.20700` needs only libm and libc, and
     pkg-config finds it. Then `developer/build/ninja` was installed (meson
     builds need it), and polkit's full `gmake prep` passes. 
   - **polkit 125 built and published (2026-11-08, ~23 s compile),**
     `system/library/polkit@125` in `oi-gnome`, pkglint clean. Fixes
     on the way, all in `packages/sysutils/polkit`:
     - `CFLAGS += -D_POSIX_PTHREAD_SEMANTICS -D__EXTENSIONS__`: illumos only
       gives the POSIX `getpwuid_r()` and declares `setnetgrent()` & co.
       with these.
     - Solaris' gcc14 PAM patch **dropped**. illumos' `<security/pam_appl.h>`
       has the const prototypes (unless `_PAM_LEGACY_NONCONST`), which is
       what polkit's upstream code uses. Solaris' PAM headers differ here.
     - New `11-duktape-log-level.patch`: an upstream bug in 125's duktape
       backend (three `polkit_backend_authority_log()` calls without the
       log level), which gcc 14 rejects. Suitable for upstream.
     - `REQUIRED_PACKAGES += SUNWcs shell/ksh93`: pkgdepend resolves only
       against these, and the SMF milestones and `/sbin/sh` come from them.
     - User renamed `_polkitd` → **`polkitd`** (uid 63). OI's pkglint
       warns on names that don't start with a lower-case letter.
     - Explicit `depend` on `library/xdg/consolekit` (polkitd only reaches
       it over D-Bus, so pkgdepend can't see it).
     - pkglint's `userland.manifest1001` refuses dependencies on non-OI
       publishers. `tools/oi-sync.sh` now adds `oi-gnome` to
       `userland.manifest.allowed_pubs` in the checkout's
       `tools/pkglintrc`, idempotently. This is the only local change to
       the oi-userland tree.
     - All files in the proto area are shipped; nothing is missing.
   - **polkit installed in the current BE and tested (2026-11-08, user OK):**
     - `pkg install system/library/polkit` from `oi-gnome` created user
       `polkitd` (63, group daemon) and the setuid `pkexec` and
       `polkit-agent-helper-1`, and fired both actuators (manifest-import,
       dbus refresh). `svc:/system/polkit` came up online, with polkitd
       running as `polkitd` and owning `org.freedesktop.PolicyKit1` on the
       system bus. dbus, consolekit and lightdm stayed online.
     - `pkaction` lists the actions. `pkcheck` on
       `org.freedesktop.policykit.exec` gives "requires authentication"
       (rc 2) without an agent, as it should.
     - **duktape rules engine verified:** a temporary rule in
       `/etc/polkit-1/rules.d` returning YES made `pkcheck` pass (rc 0).
       After the file was removed it failed again (rc 2), so rule changes are
       picked up live. The test rule is deleted.
     - After the VM reset at 23:33, `svc:/system/polkit` came up online on
       its own at boot.
     - Not yet tested: an authentication agent (pkttyagent / the
       gnome-shell agent) and ConsoleKit session state
       (`subject.local`/`active`) from a real desktop login.
   - **accountsservice 0.6.55 and colord 1.4.7 built and published
     (2026-11-08, ~23:47), not installed:**
     - `packages/sysutils/accountsservice`: Solaris patches 0001-0005 plus
       new `0006-illumos-wtmpx.patch`. illumos' `<utmpx.h>` has
       `WTMPX_FILE`, not glibc's `WTMPX_FILENAME`; suitable for upstream.
       Admin group `staff`, daemon `/usr/libexec/accounts-daemon` under
       SMF `svc:/system/accountsservice` (root, as on Solaris).
       `/var/lib/AccountsService/{icons 0775,users 0700}`.
     - `packages/library/colord`: Solaris patches 02-07 (07 without its
       `<lcms/lcms2.h>` hunk), no 08-lssp, no `-fstack-protector-all`.
       New: `09-dummy-sensor-lcms.patch` (the module lacked its lcms
       dependency) and `10-version-script-illumos.patch`. illumos ld has no
       `--version-script`, and Solaris 11.4's `-z
       gnu-version-script-compat` doesn't exist on illumos either, so the
       libraries link without symbol versioning. Both are suitable for
       upstream. 64-bit only, no vala bindings. SMF `svc:/system/colord`
       (child service) runs `/usr/libexec/colord` as `daemon`, which owns
       `/var/lib/colord` (Solaris' extended privilege
       `{zone}:/var/lib/colord/*` doesn't exist on illumos).
     - p5m from `gmake sample-manifest`, plus state dirs and
       `refresh_fmri=svc:/system/dbus:default` on the D-Bus policies.
       pkglint has no errors. Resolved dependencies are as expected
       (polkit, dbus, glib2, plus lcms2 and sqlite for colord).
     - **Overnight decision (user asleep):** not installed. Both are SMF
       services that start at once, and lightdm queries AccountsService for
       its user list, so installing could change the MATE login with nobody
       to fix it. To do with the user's OK: `sudo -n pkg install
       system/library/accountsservice service/image/colord`, then check
       both services, `gdbus introspect` on `org.freedesktop.Accounts` /
       `org.freedesktop.ColorManager`, `colormgr get-devices`, and the
       lightdm login.
     - Small open point: colord reads `/usr/share/hwdata/pci.ids` (from
       `system/data/hardware-registry`) at runtime only, so pkgdepend
       did not add it. An explicit `depend` would be cleaner on the next
       republish.
   - **VM incident 2026-11-08 23:07–23:33:** the toolchain session's
       `gmake sample-manifest` triggered a full gcc 14 rebuild (24 jobs).
       Together with these two builds the guest reached its 32 GB, sshd
       starved, and the user reset the VM. Lessons: check `vmstat` before
       each build, and know that `sample-manifest` can rebuild. Tonight's
       rule (relayed from the user): at most -j8 alongside the toolchain
       build.
   - **Night of 2026-11-08/09 (user: "install without asking", wants a
     GNOME 3 desktop in the morning).** Installed in the current BE from
     `oi-gnome`: accountsservice and colord (tested: both SMF services
     online, `org.freedesktop.Accounts` lists the build user, `colormgr` sees
     the built-in profiles; lightdm unaffected), geoclue 2.7.2,
     geocode-glib-2 (new: the libsoup 3 build, API 2.0, which libgweather 4
     needs; OI's geocode-glib is the libsoup 2 build), Cantarell 0.301,
     libgweather 4.4.4 and mutter 45.7. OI build deps installed: geocode-glib,
     gjs, mozjs-140, gnome-desktop, libical, libxcvt, sassc, gcr-4.
   - **IPS trap: OI's userland-incorporation version-locks the old GNOME 2
     names** (`facet.version-lock.<name>=true` at the obsolete version):
     libgweather 3.24.1, evolution-data-server 3.24.0, gnome-session 2.32.1,
     gnome-settings-daemon 2.32.1, control-center 2.32.1, gdm 2.30.7. Our
     newer packages are rejected ("excluded by installed incorporation") or
     `pkg install <name>` silently says "No updates necessary". Done on the
     VM: `pkg change-facet facet.version-lock.<name>=false` for libgweather,
     evolution-data-server, gnome-session and gnome-settings-daemon
     (control-center and gdm still to do), then install with an explicit
     `@version`. To undo: set the facets back to `true`. For OI upstreaming,
     the incorporation itself would drop those entries.
   - Tools: `tools/sample-to-p5m.py` (sample manifest to p5m, with dbus
     refresh) and `tools/oi-pipeline.sh` (sync, build `-j N` via
     `NINJA=ninja -jN`, sample-manifest without rebuild (`-o` on the
     absolute `.prep`/`.unpacked` stamps), draft p5m and license, publish,
     install).
   - mutter: built on the first try with all Solaris patches. The manifest
     needed the X11/pango/cairo libraries in `REQUIRED_PACKAGES` (pkgdepend
     only resolves against those), plus `pkg.depend.bypass-generate` on the
     dlopen()ed default plugin.
   - **Later that night:** gnome-autoar 0.4.5, libgdm (gdm 45.0.1 built
     whole with all 29 Solaris patches plus `-D_PAM_LEGACY_NONCONST` and
     `-lsocket -lnsl`; packaged as client lib + typelib + login-screen
     schema only), gnome-settings-daemon 45.1 and gnome-session 45.0 are
     built, published and installed. evolution-data-server 3.50.3 is built.
     The fixes found on the way:
     - e-d-s: no Kerberos (illumos has no public libkrb5),
       `CFLAGS += $(XPG6MODE)` (POSIX `iconv()` prototype, as Solaris),
       `system/library/iconv/extra` + `unicode` (the iconv-detect test
       needs ISO-2022-JP), `LDFLAGS += -lsocket -lnsl` (getaddrinfo) and
       `-licuuc` (replaces Solaris' icu.patch), `developer/gperf`.
     - g-s-d: `06-upower-0.99.11.patch`. OI ships upower 0.99.11, and 45.1
       wants 0.99.12 only for the new device kinds, so they are defined
       past `UP_DEVICE_KIND_LAST`; OI-only. `07-tz-islower.patch`
       (upstream bug: a pointer passed to islower(), which gcc 14 rejects).
       Disabled plugins (rfkill, wacom, wwan) install upstream's
       `Hidden=true` dummy autostart files, which satisfy gnome-session's
       required-components list.
     - gnome-session: needs `x11/library/xtrans`. It installs
       /usr/share/xsessions/gnome.desktop and gnome-xorg.desktop for lightdm.
     - `tools/oi-deps.sh` maps pkgdepend's unresolved files to packages
       via an index of the VM's installed files (`pkg search` is too slow
       there).
     - `tools/oi-pipeline.sh` now installs `FMRI@version` and checks it
       with `pkg list`: with a bare name, the incorporation trap is silent.
       Its memory guard counts free + ZFS ARC (`::memstat`) and needs
       6 GB.
   - **GNOME Shell 45.9 runs (2026-11-09 ~02:50).** evolution-data-server,
     gnome-shell (+ gnome-session, g-s-d, mutter, all earlier pieces) are
     installed in the current BE. In an Xvfb test, `gnome-session
     --session=gnome` brings up gnome-shell (top bar, overview, app grid)
     and the g-s-d plugins, and keeps running.
     - **gjs 1.90 vs gnome-shell 45** (the risk in 3b): gnome-shell 45 links
       libgirepository-1.0, while gjs >= 1.79 uses GLib's girepository-2.0.
       Both register `GIRepository` ("cannot register existing type"), and
       the shell then cannot find `Meta-13`. Fixed with
       `21-girepository-2.0.patch` (6 calls in main.c, includes, meson:
       link girepository-2.0, the same port upstream made for GNOME 47). So
       no mozjs-115/gjs-1.78 is needed.
     - e-d-s also needed `$(GCC_RUNTIME_PKG) $(GXX_RUNTIME_PKG)`.
       gnome-shell needed versioned python shebangs for its two tool
       scripts (as Solaris) and `pygobject-39`/`simplejson-39`.
     - **OI's system bus does not activate services** (no setuid
       `dbus-daemon-launch-helper`, `ListActivatableNames` is empty), so
       every system service needs SMF. geoclue got `svc:/system/geoclue`
       (root, as its D-Bus file says); polkit, accountsservice and colord
       already had theirs.
     - Expected warnings left: no logind (suspend inhibit), no Settings
       app (gnome-control-center not built yet), the
       `org.gnome.settings-daemon.peripherals.mouse` schema missing for
       gsettings-data-convert, and nwam-manager autostarting in the GNOME
       session too.
     - **Not yet done:** a real login through lightdm on the VM console
       (pick "GNOME" in the lightdm session menu). It needs the user at the
       console. (Later done through gdm, on the VM and on the iMac: see
       below.) The Xvfb test does not cover ConsoleKit session tracking or
       the polkit agent.
   - **GNOME Settings (gnome-control-center 41.7) installed (~03:28),**
     with colord-gtk 0.3.1 and gsound 1.0.3. The Settings window opens in
     the Xvfb session (Background, Notifications, Sound, Displays,
     Keyboard, Color, Region...). Fixes: `16-goa-optional.patch` (meson
     still required goa-1.0 after Solaris removed the Online Accounts
     panel); `library/libhandy` is OI's FMRI; the desktop file is renamed
     to `org.gnome.Settings.desktop` (the name gnome-shell 45 looks for;
     g-c-c 41 used gnome-control-center.desktop). gsound's switch is
     `enable_vala`. Version-lock facet also lifted for
     `gnome/preferences/control-center`.
     - Xvfb screenshots show stripes on pictures (the OI wallpaper
       thumbnail) and a narrower shell stage. These are probably
       Xvfb/softpipe artifacts (the first screenshot was clean); check on
       the real VM display.
     - `tools/oi-pipeline.sh` now installs missing OI build deps before
       building, and on "unresolved dependency" adds the packages from
       `tools/oi-deps.sh` to the Makefile and retries the publish once.
     - Test runs go inside `ctrun -l child -o noorphan` so that only the
       test's own processes are stopped (no pkill by name).
   - **gdm 45.0.1 is the display manager (2026-11-09 morning).** The
     component moved to `packages/desktop/gdm` and makes two packages:
     `library/desktop/libgdm` and `system/display-manager/gdm`, with the
     SMF service `svc:/application/graphical-login/gdm` (installed
     disabled). Version-lock facet lifted for `system/display-manager/gdm`
     (OI's old 2.30.7). OI's SUNWcs already has the gdm user and group
     (50). Three illumos patches on top of Solaris' 29:
     - `0030-illumos-greeter-pam`: Solaris gives the greeter its PAM stack
       through user_attr `pam_policy`, which illumos lacks, and packages
       cannot amend pam.conf. The greeter uses OI's existing
       `gdm-autologin` stack (pam_allow), the same stack Solaris uses.
     - `0031-illumos-ck-libexec`: ConsoleKit's ck-get-x11-display-device
       is in /usr/libexec on OI.
     - `0032-illumos-pam-tty`: gdm sets PAM_TTY only when logind reports
       VTs on seat0. illumos' pam_unix_session refuses a session without
       PAM_TTY ("Can not make/remove entry for session"). The symptom was
       a black screen, with "Session never registered, failing" in the SMF
       log.
     - Switched with `svcadm disable lightdm; svcadm enable gdm`; back the
       other way round. Debug output is on in /etc/gdm/custom.conf
       (`[debug] Enable=true`) and goes to the SMF log.
     - A GNOME session started from lightdm on the old VBoxVGA controller
       showed only the X background: gnome-shell ran but nothing it drew
       appeared. Since the switch to VBoxSVGA (done by the user and the
       Solaris session) the gdm greeter (gnome-shell) draws fine.
   - **First GNOME apps and Dash to Dock (2026-11-09),** at the user's
     request, published to oi-gnome and installed on the VM:
     - `terminal/gnome-terminal` 3.60.0 (GTK3 + libhandy + vte 0.84, which
       matches OI's vte-291 0.84.1; Solaris ships 3.41 on vte 0.66).
       Fixes: `01-w-exitcode.patch` (illumos has no W_EXITCODE) and
       `-lsocket -lnsl` (socketpair). No Nautilus extension; systemd user
       unit left out.
     - `desktop/system-monitor/gnome-system-monitor` 42.0, the last GTK3
       release (43+ need gtkmm-4.0, which OI lacks). `-lsocket -lnsl`
       (getnameinfo). It logs libgtop warnings for /proc files of other
       users' processes, and those rows show no name.
     - `gnome/gnome-shell/extension/dash-to-dock` 90 (Shell 45 and 46).
       v89 failed on 45.9: its wrapper around the async
       `_prepareStartupAnimation` drops the promise ("JS ERROR ... is
       undefined"). `10_dash-to-dock.gschema.override` sets
       `enabled-extensions=['dash-to-dock@micxgx.gmail.com']` and
       `dock-fixed=true`. It is built in a real copy of the sources, not a
       cloney one: its Makefile copies with `cp -r` and would package the
       symlinks.
     - The Extensions app (`gnome-extensions-app`) was already part of
       gnome-shell 45.9 and starts.
     - Version-lock facets lifted for `terminal/gnome-terminal` and
       `desktop/system-monitor/gnome-system-monitor` (old GNOME 2 builds in
       OI's incorporation).
     - Still to do for apps: a file manager (nautilus 42+ needs tracker 3,
       libportal and gexiv2) and a text editor (gnome-text-editor needs
       gtksourceview-5 and libspelling). MATE's caja and pluma work in the
       GNOME session meanwhile.
   - **Real hardware (2026-11-09 09:44):** on the user's iMac13,2 (OI
     2026.10, osnet 23381, NVIDIA 470 driver on a GTX 675MX), the oi-gnome
     packages were installed from a p5p into BE `gnome45` (by the iMac
     session), and gdm 45.0.1 replaced lightdm (`svcadm`). gdm's greeter
     came up, the user logged into GNOME 45 through it, and called it
     "really very snappy". So gdm and a real login session work on illumos
     with hardware GL. Not checked separately there: ConsoleKit session
     state and the polkit authentication dialog.
2. **Data libraries:** `fonts/cantarell` → `library/desktop/libgweather`
   4.4.4 → `library/desktop/evolution-data-server` 3.50.3 →
   `library/desktop/gsound` → `gnome/gnome-menus` →
   `gnome/gnome-backgrounds`.
3. **Session:** `gnome/window-manager/mutter` 45.7 →
   `gnome/gnome-settings-daemon` 45.1 → `gnome/gnome-shell` 45.9 (against
   OI's gjs 1.90, see 3b) → `gnome/gnome-session` 45.0 (+ xsession file
   for lightdm) → `gnome/gnome-shell-extensions` 45.2 +
   background-logo-extension → `gnome/preferences/control-center` 41.7 →
   `gnome/gnome-tweaks`, `mousetweaks`.
   **Milestone: a GNOME 45 session from lightdm in a test BE.** Compare it
   with the Solaris 11 CBE VM as the reference.
4. **gdm 45.0.1** with the reworked Solaris patches and an SMF manifest
   next to lightdm's (only one enabled). **Done 2026-11-09**, see above.
5. **Apps**, in order of usefulness: gnome-terminal, nautilus 3.34 (with
   tracker-2/tracker-miners-2, gnome-autoar, exempi), eog, evince, gedit,
   gnome-calculator, gnome-screenshot, gnome-font-viewer, clocks,
   calendar, gnome-user-docs.
6. **Optional:** rebuild OI's mesa with LLVM (llvmpipe) if softpipe is too
   slow. Fallback mozjs-115 + gjs 1.78, only if 3b fails.

Rough size: about 20 new components to a working session (tiers 1–3),
plus about 15 for apps.

## 5a. GNOME applications (2026-11-09)

Requested by the user: the default GNOME applications, as oi-userland
components, from solaris-userland where it has them. OI already has
GNOME 47's library level: GTK 4.16.13, libadwaita 1.6.10,
gtksourceview-5 5.14.2, vte 0.84.1, libpeas-2, gspell-3, libgee 0.20.8,
vala 0.56 and gexiv2 0.14.6 (some only in the repository, not installed).
So the GTK4 apps use their **GNOME 47** releases, which need exactly
libadwaita 1.6 and GTK 4.15+. The GTK3 apps follow Solaris 11.4's
versions.

| App | Version | Toolkit | Source | Needs (new = our component) |
|---|---|---|---|---|
| gnome-terminal | 3.60.0 | GTK3, vte 0.84 | upstream (Solaris: 3.41 on vte 0.66) | done |
| gnome-system-monitor | 42.0 | GTK3, gtkmm3 | upstream (not in Solaris) | done |
| gnome-text-editor | 47.4 | GTK4, adw 1.6 | upstream (Solaris ships gedit 41) | gtksourceview-5 (OI), **libspelling 0.4.11** |
| gnome-calculator | 47.3 | GTK4, adw 1.6 | upstream (Solaris: 41.0) | libgee, vala, gtksourceview-5 (OI) |
| baobab (Disk Usage Analyzer) | 47.0 | GTK4, adw 1.6 | upstream | vala (OI) |
| eog (Image Viewer) | 45.4 | GTK3, libhandy | Solaris 11.4 (45.2) + patches | libpeas-1, libexif (OI); exempi off |
| evince (Document Viewer) | 48.4 | GTK3, libhandy | Solaris 11.4 (48.4) + patches | poppler, libspectre, djvulibre (OI); libgxps off |
| file-roller (Archive Manager) | 44.7 | GTK4, adw | upstream | libarchive (OI), **libportal 0.11.0** |
| nautilus (Files) | 47.6 | GTK4, adw 1.6 | upstream (Solaris: 3.34 on tracker 2) | **libportal**, **tinysparql 3.8.2** (Tracker 3), gexiv2, gnome-autoar |
| totem (Videos) | 43.1 | GTK3, libhandy | Solaris 11.4 (43.1) + patches; **OI already ships 42.0** | gstreamer, gst-plugins-base, grilo, libpeas-1 (OI). H.264 playback depends on OI's gst-plugins-good and gst-libav (hipster-encumbered, on ffmpeg) being installed, not on the totem version; 43.1 only if 42.0 falls short |
| gnome-screenshot | 41.0 | GTK3, libhandy | Solaris 11.4 (41.0) + patches | - |
| gnome-backgrounds | 47.0 | images | upstream (Solaris: 41.0) | - |
| adwaita-icon-theme | 50.0 | | OI as is | - |
| gnome-disk-utility | - | | **left out** | needs udisks2, which does not exist on illumos |

Build order (one at a time on the VM, memory checked first): libspelling →
gnome-text-editor → gnome-calculator → baobab → gnome-backgrounds →
gnome-screenshot → eog → evince → libportal → file-roller → tinysparql →
nautilus → totem. Nautilus' search works without localsearch (the file indexer),
which is left out for now.

gnome-control-center 41.7 panels still missing (removed by Solaris'
patches or by our builds): Online Accounts (no goa), Network and Wi-Fi
(NetworkManager), Bluetooth, Wacom, Thunderbolt, Printers (no
cups-pk-helper), Sharing (no systemd). OI equivalents are separate
tools (nwam-manager, system-config-printer). To decide later.

## 5b. Removable drives: automount and unmount (2026-11-09)

Requested: USB drives with NTFS (and FAT/exFAT) mount automatically for the
user under /media/<label>, show in Files and the dock, and unmount from the
desktop as the user. No udisks2 on illumos; the route is the existing
HAL + rmvolmgr + gvfs-hal-volume-monitor chain (all in OI: service/hal
0.5.11 from illumos-gate, rmvolmgr online, gvfs 1.26's HAL monitor runs in
GNOME sessions).

- **Why nothing mounted** (iMac, USB 3 drive, GPT: s0 Microsoft
  reserved, s1 NTFS): HAL creates the storage device
  (`storage.partitioning_scheme='gpt'`, `storage.hotpluggable=true`) but
  no volumes. hald-probe-storage sets `storage.solaris.vtoc_slices` only
  for VTOC labels; devinfo_storage.c then skips every slice but s2 (illumos-gate
  usr/src/cmd/hal/probing/storage/probe-storage.c,
  hald/solaris/devinfo_storage.c). hald-probe-volume itself can read GPT
  partitions (efi_alloc_and_read).
- **First attempt, a policy file only:** `system/hal/removable-gpt`
  (published in oi-gnome, component since removed), an fdi in
  /etc/hal/fdi/policy/20thirdparty that sets vtoc_slices for GPT disks
  (plus the ntfs-3g mount options). Installed on the iMac with the user's
  OK on 2026-11-09 11:23: **not enough.** hald applies the file (a test
  rule's marker properties appear on the disk), but HAL adds a USB disk's
  volumes in a storage *rescan*, and every rescan runs hald-probe-storage
  again, which resets vtoc_slices to false and does not re-merge fdi files
  (devinfo_storage_rescan_probing_done). Turning media checking off for the
  disk does not change that. So the fix has to be in hald-probe-storage:
  set vtoc_slices for GPT (probe-storage.c, the `efi_alloc_and_read`
  branch). That is one line in illumos-gate; for OI now it means a patched
  prober, either upstream or as our own package (decision pending).
- **Mounting:** rmvolmgr mounts every volume of a removable or hotpluggable
  disk through HAL's Mount() with no options; hal-storage-mount runs
  `mount -F <fstyp name>`, i.e. `mount -F ntfs-3g`, read-write. A
  hibernated Windows volume (Fast Startup) is not forced: ntfs-3g itself
  falls back ("Could not mount read-write, trying read-only"). A read-only
  default for NTFS would need a change in hal-storage-mount (illumos-gate)
  or an rmvolmgr option: not done.
- **Rights:** every user has `solaris.device.mount.removable` (Basic
  Solaris User), which HAL's libpolkit checks for Mount/Unmount, so the
  desktop's eject button (gvfs HAL monitor → HAL Unmount) works as the
  user.
- **Second step, a patched prober:** `system/hal/probe-storage-gpt`
  (packages/sysutils/hal-probe-storage-gpt): illumos-gate's
  hald-probe-storage (commit b1c424a2, tarball from GitHub) with
  `patches/0001-NNNNN-hal-*.patch` (vtoc_slices = TRUE for GPT), the same
  file as the illumos-gate submission in ports/hal-gpt-volumes/upstream
  (issue text, testing, steps; the user files it), built 64-bit
  and installed as /usr/lib/hal/oi/hald-probe-storage. hald uses it once
  `svccfg -s system/hal setenv HALD_RUNNER_PATH /usr/lib/hal/oi` is set
  (hald_runner.c puts that path first). With it HAL creates volumes s0..s15.
- **Third step, an NTFS fstyp module:** `system/file-system/fstyp-ntfs`
  (packages/sysutils/fstyp-ntfs, our own C): ntfsprogs ships only a shell
  script as /usr/lib/fs/ntfs-3g/fstyp, which fstyp(8) runs but libfstyp
  (and so hald-probe-volume) does not ("fstyp ident or get_attr failed").
  The module reads the boot sector and the $Volume record (label, NTFS
  version, clean flag); 32-bit, like hald-probe-volume. Tested on the VM
  against an mkntfs image (UTF-8 label) and on the iMac drive.
- **Result on the iMac (2026-11-09 12:38):** HAL shows the NTFS partition
  (`volume.fstype='ntfs-3g'`, the label, `fsusage=filesystem`), rmvolmgr
  mounts it at /media/<label>, read-write (`nosuid`), and the GNOME session
  lists it (gvfs HAL monitor: "USB Drive" and the mount). After a HAL
  restart rmvolmgr has to be restarted too (it does not reconnect).
- **Eject from the desktop (2026-11-09 15:30), three more fixes:**
  1. `system/hal/removable-media-policy` (packages/sysutils/hal-removable-media):
     a D-Bus policy that allows HAL's Volume/Storage interfaces for group
     staff. OI's dbus has no console auth dir, so `at_console` is never
     true and hal.conf allowed them for root only. HAL still checks
     solaris.device.mount.removable.
  2. `system/file-system/ntfsprogs` 2026.9.28 revision 1 (oi-gnome;
     packages/sysutils/ntfsprogs, OI's component plus
     `02-illumos-mnttab-device.patch`): ntfs-3g records the device as given
     (/dev/dsk/...) in mnttab, not its /devices realpath. gvfs now ties the
     mount to its HAL volume. Needs facet.version-lock for ntfsprogs off;
     the installed package's publisher becomes oi-gnome, so OI's later
     ntfsprogs updates need this component rebuilt (or `pkg set-publisher`
     / reinstall from openindiana.org to go back).
  3. `system/hal/storage-fuse` (packages/sysutils/hal-storage-fuse):
     hal-storage-mount/unmount with a second illumos-gate patch
     (ports/hal-fuse-mounts/upstream): hald matches mnttab to volumes by
     device number, which FUSE mounts do not carry, so HAL thought the
     volume unmounted ("NotMounted"; and Mount mounted it twice). The tools
     now also look for the device name in mnttab. 32-bit, in
     /usr/lib/hal/oi.
  - Result on the iMac: `gio mount -u` as the user unmounts the drive (the
    eject button's path); HAL Mount as the user mounts it; a second Mount
    is refused (AlreadyMounted). `gio mount -d` hangs: not looked into yet.
    `volume.is_mounted` itself stays false for FUSE mounts (hald, a
    further illumos change).
- **State of the iMac:** probe-storage-gpt, fstyp-ntfs, storage-fuse,
  removable-media-policy and ntfsprogs rev. 1 installed in BE
  gnome45-audiohd (removable-gpt uninstalled again, 12:45); HALD_RUNNER_PATH set on svc:/system/hal. The
  user's drive is back on its manual read-only mount;
  on the next plug-in, HAL or rmvolmgr restart, rmvolmgr mounts it
  read-write at /media/<label>.
- exFAT: OI's system/file-system/exfat 1.3.0 (fuse) is not installed on the
  iMac; its fstyp name decides whether the same chain works.

### iMac session ends, 2026-11-09 10:41 and 10:52

The X server terminated normally each time ("Server terminated
successfully"), so no X or NVIDIA crash: gdm closed the display after the
session had ended. The 10:14-10:41 session log had about 7100 identical
gnome-shell JavaScript stack traces from js/ui/dnd.js (drag and drop), then
a gnome-shell restart at 10:41:02 and the end of the session. The cause
of the dnd.js errors is not known: gdm keeps only one old session log, and
the user's next logins (10:51, 10:56) overwrote it. The 10:51 session
lasted one minute and ended the same clean way (a logout or gnome-session
exiting). The Totem/GStreamer install (10:45) came after the 10:41 end.
The warnings "GetSessionClass failed: Not owner" and gsettings-data-convert
"crashing too quickly" appear in every session (VM too) and are harmless.

## 6. Decisions

Made by the user on 2026-11-08:

1. Plan and build order: **approved**.
2. polkit JS engine: **duktape** (new component `library/duktape`).
3. Build dependencies from the openindiana.org publisher: **install as
   needed** with `sudo -n pkg install` into the current BE (build tools and
   libraries only), naming each set first.
4. accountsservice admin group: **`staff`**. Caveat: `staff` is
   OpenIndiana's default group for every user, so every user will show
   as "Administrator" in the Users panel, and switching a user to
   "Standard" there removes them from `staff`. If that turns out wrong, a
   dedicated group (e.g. `sysadmin`) is a one-line Makefile change.

Still open:

5. Publisher `oi-gnome`: **added** (user OK, 2026-11-08). Build
   dependencies such as duktape go into the current BE. The GNOME session
   packages go into a **new test boot environment**, to be asked when they
   are ready.
6. Whether the mesa LLVM rebuild (tier 6) is in scope.

---

## Appendix: all solaris-userland `gnome/` and `desktop/` components vs oi-userland

Matched by component name, plus an alias list (e.g. glib2 → library/glib,
gtk3 → library/gtk+3). "missing" means no oi-userland component of that
name was found. A few of these may exist under another name: check before
writing one.

| solaris-userland component | Solaris 11.4 | oi-userland (as of 2cadaa12) |
|---|---|---|
| desktop/accountsservice | 0.6.55 | **missing** |
| gnome/adwaita-icon-theme | 41.0 | desktop/adwaita-icon-theme 50.0 |
| gnome/at-spi2-core | 2.58.1 | desktop/gnome/at-spi2-core 2.62.1 |
| gnome/atkmm | 2.28.2 | library/atkmm 2.28.4 |
| gnome/background-logo-extension | 45.beta | **missing** |
| desktop/brltty | 6.4 | library/brltty 6.7 |
| desktop/cairo | 1.18.4 | library/cairo 1.18.6 |
| desktop/cairomm | 1.12.2 | library/cairomm 1.14.5 |
| gnome/cantarell-fonts | 0.301 | **missing** |
| desktop/colord | 1.4.7 | **missing** |
| desktop/colord-gtk | 0.3.1 | **missing** |
| desktop/consolekit | 0.4.1 | library/ConsoleKit 0.4.6 |
| desktop/dbus | 1.16.0 | library/dbus 1.16.2 |
| desktop/dbus-glib | 0.114 | library/dbus-glib 0.116 |
| desktop/dbus-python | 1.4.0 | python/dbus-python 1.3.2 |
| gnome/dconf | 0.40.0 | desktop/gnome2/dconf 0.40.0 |
| gnome/dconf-editor | 45.0.1 | desktop/gnome2/dconf-editor 45.0.1 |
| desktop/desktop-file-utils | 0.28 | desktop/desktop-file-utils 0.28 |
| desktop/dotconf | 1.4.1 | library/dotconf 1.4.1 |
| gnome/eog | 45.2 | **missing** |
| gnome/eog-plugins | 44.1 | **missing** |
| desktop/espeak-ng | 1.52.0 | (library/espeak 1.48.04, not espeak-ng) |
| gnome/evince | 48.4 | **missing** |
| gnome/evolution-data-server | 3.50.3 | **missing** |
| desktop/exempi | 2.6.6 | **missing** |
| desktop/firefox | 153.5.1 | web/firefox 159.0.1 |
| desktop/flac | 1.5.0 | multimedia/flac 1.5.0 |
| gnome/fribidi | 1.0.16 | library/fribidi 1.0.18 |
| gnome/gcr | 3.38.0 | library/gcr 3.41.2 |
| gnome/gcr-4 | 4.1.0 | desktop/gnome/gcr-4 4.4.0.1 |
| gnome/gdk-pixbuf | 2.44.8 | library/gdk-pixbuf 2.44.8 |
| gnome/gdm | 45.0.1 | **missing** |
| gnome/gedit | 41.0 | **missing** |
| gnome/gedit-plugins | 41.0 | **missing** |
| desktop/geoclue | 2.7.2 | **missing** |
| gnome/geocode-glib | 3.26.4 | desktop/gnome/geocode-glib 3.26.4 |
| gnome/gjs | 1.78.5 | library/gjs 1.90.1 |
| gnome/glade | 3.40.0 | developer/glade 3.40.0 |
| gnome/glib-networking | 2.90.1 | library/glib-networking 2.80.1 |
| gnome/glib2 | 2.89.3 | library/glib 2.86.5 |
| gnome/glibmm | 2.66.6 | library/glibmm 2.66.8 |
| gnome/gmime-3 | 3.2.7 | library/gmime3 3.2.15 |
| gnome/gnome-autoar | 0.4.5 | **missing** |
| gnome/gnome-backgrounds | 41.0 | **missing** |
| gnome/gnome-browser-connector | 42.0 | **missing** |
| gnome/gnome-calculator | 41.0 | **missing** |
| gnome/gnome-calendar | 41.2 | **missing** |
| gnome/gnome-clocks | 44.0 | **missing** |
| gnome/gnome-control-center | 41.7 | **missing** |
| gnome/gnome-desktop | 44.0 | desktop/gnome/gnome-desktop 44.4 |
| gnome/gnome-font-viewer | 41.0 | **missing** |
| gnome/gnome-getting-started-docs | 3.38.1 | **missing** |
| gnome/gnome-initial-setup | 41.4 | **missing** |
| gnome/gnome-keyring | 46.2 | desktop/gnome/gnome-keyring 46.2 |
| gnome/gnome-menus | 3.36.0 | **missing** |
| gnome/gnome-online-accounts | 3.58.1 | **missing** |
| gnome/gnome-screenshot | 41.0 | **missing** |
| gnome/gnome-session | 45.0 | **missing** |
| gnome/gnome-settings-daemon | 45.1 | **missing** |
| gnome/gnome-shell | 45.9 | **missing** |
| gnome/gnome-shell-extensions | 45.2 | **missing** |
| gnome/gnome-terminal | 3.41.0 | **missing** |
| gnome/gnome-tweaks | 45.1 | **missing** |
| gnome/gnome-user-docs | 45.1 | **missing** |
| gnome/gobject-introspection | 1.84.0 | library/gobject-introspection 1.86.0 |
| gnome/gom | 0.5.3 | desktop/gnome/gom 0.5.5 |
| gnome/graphene | 1.10.8 | library/graphene 1.10.8 |
| gnome/grilo | 0.3.19 | desktop/gnome/grilo 0.3.19 |
| gnome/grilo-plugins | 0.3.18 | desktop/gnome/grilo-plugins 0.3.18 |
| gnome/gsettings-desktop-schemas | 45.0 | desktop/gnome/gsettings-desktop-schemas 50.1 |
| gnome/gsound | 1.0.3 | **missing** |
| desktop/gstreamer1/gst-plugins-base | 1.28.8 | multimedia/gst-plugins-base 1.28.9 |
| desktop/gstreamer1/gst-plugins-good | 1.28.8 | multimedia/gst-plugins-good 1.28.9 |
| desktop/gstreamer1/gst-python | 1.28.8 | encumbered/gst-python 1.26.6 |
| desktop/gstreamer1/gstreamer | 1.28.8 | multimedia/gstreamer 1.28.9 |
| gnome/gtk-doc | 1.34.0 | developer/gtk-doc 1.35.1 |
| gnome/gtk3 | 3.24.51 | library/gtk+3 3.24.52 |
| gnome/gtk4 | 4.14.5 | library/gtk4 4.16.13 |
| gnome/gtkmm3 | 3.24.8 | library/gtkmm3 3.24.9 |
| gnome/gtksourceview | 4.8.4 | library/gtksourceview-4 4.8.4 |
| gnome/gucharmap | 15.1.2 | desktop/gnome/gucharmap 18.0.0 |
| gnome/gvfs | 1.56.3 | library/gvfs 1.26.3 |
| desktop/harfbuzz | 12.3.0 | library/harfbuzz 15.1.0 |
| desktop/hicolor-icon-theme | 0.18 | desktop/hicolor-icon-theme 0.18 |
| desktop/itstool | 2.0.7 | text/itstool 2.0.7 |
| gnome/json-glib | 1.8.0 | library/json-glib 1.10.6 |
| desktop/lgi | 0.9.2 | library/lgi 0.9.0 |
| gnome/libadwaita | 1.3.6 | library/libadwaita 1.6.10 |
| desktop/libcanberra | 0.30 | library/libcanberra 0.30 |
| gnome/libdazzle | 3.44.0 | **missing** |
| desktop/libexif | 0.6.26 | image/libexif 0.6.26 |
| gnome/libgee | 0.20.8 | library/libgee 0.20.8 |
| gnome/libgsf | 1.14.60 | library/libgsf 1.14.60 |
| gnome/libgtop | 2.41.2 | library/libgtop 2.40.0 |
| gnome/libgweather | 4.4.4 | **missing** |
| gnome/libgxps | 0.3.2 | **missing** |
| gnome/libhandy | 1.8.2 | library/libhandy 1.8.3 |
| desktop/libical | 3.0.20 | library/libical 3.0.20 |
| desktop/libjpeg | 10 | library/libjpeg-turbo 3.2.1 |
| desktop/liblouis | 3.39.0 | library/liblouis 3.35.0 |
| gnome/libmediaart | 1.9.7 | desktop/gnome/libmediaart 1.9.7 |
| gnome/libnotify | 0.8.6 | library/libnotify 0.8.9 |
| desktop/libogg | 1.3.6 | library/libogg 1.3.6 |
| gnome/libpeas | 1.36.0 | library/libpeas 1.20.0 |
| desktop/libpng16 | 1.6.59 | library/libpng16 1.6.59 |
| desktop/libproxy | 0.4.18 | library/libproxy 0.4.18 |
| gnome/librsvg | 2.56.3 | library/librsvg 2.61.4 |
| gnome/libsecret | 0.21.7 | library/libsecret 0.21.7 |
| gnome/libsoup-3 | 3.7.2 | library/libsoup3 3.6.4 |
| desktop/libspectre | 0.2.12 | library/libspectre 0.2.12 |
| desktop/libtheora | 1.2.0 | library/libtheora 1.2.0 |
| desktop/libtiff | 4.7.2 | library/tiff 4.7.2 |
| desktop/libvorbis | 1.3.7.20260803 | library/libvorbis 1.3.7 |
| desktop/libvpx | 1.14.1 | library/libvpx 1.17.0 |
| desktop/libwebp | 1.6.0 | library/libwebp 1.6.0 |
| gnome/libwnck3 | 3.32.0 | library/libwnck 43.3 |
| gnome/meld | 3.24.0 | developer/meld 3.22.3 |
| gnome/mm-common | 1.0.7 | library/mm-common 1.0.8 |
| gnome/mousetweaks | 3.32.0 | **missing** |
| desktop/mozjs-115 | 115.2.0 | **missing** |
| desktop/mozjs-140 | 140.6.0 | library/mozjs-140 140.17.0 |
| gnome/mutter | 45.7 | **missing** |
| gnome/nautilus | 3.34.0 | **missing** |
| desktop/openjpeg | 2.5.3 | library/openjpeg 2.5.4 |
| desktop/gstreamer1/orc | 0.4.44 | library/orc 0.4.44 |
| gnome/orca | 45.2 | desktop/gnome/orca 47.3 |
| desktop/os-welcome | 1.3.1 | **missing** |
| desktop/p11-kit | 0.26.5 | library/p11-kit 0.26.5 |
| gnome/pango | 1.56.4 | library/pango 1.58.0 |
| gnome/pangomm | 2.46.3 | library/pangomm 2.46.4 |
| desktop/pcaudiolib | 1.3 | **missing** |
| desktop/polkit | 125 | **missing** |
| desktop/poppler | 26.09.0 | library/poppler 26.02.0 |
| desktop/pulseaudio | 14.2 | desktop/pulseaudio 17.0 |
| gnome/pygobject3 | 3.58.0 | python/PyGObject 3.54.3 |
| desktop/qt6 | 6.11.2 | library/qt6 6.10.3 |
| desktop/rdesktop | 1.9.0 | desktop/rdesktop 1.9.0 |
| gnome/seahorse | 47.0.1 | desktop/gnome/seahorse 47.0.1 |
| desktop/shared-mime-info | 2.4 | desktop/shared-mime-info 2.4 |
| gnome/sigcpp | 2.12.1 | library/libsigc++ 2.10.0 |
| desktop/speech-dispatcher | 0.12.1 | library/speech-dispatcher 0.10.2 |
| desktop/speex | 1.2rc1 | multimedia/speex 1.2.1 |
| desktop/startup-notification | 0.12 | library/startup-notification 0.12 |
| desktop/taglib | 1.13.1 | multimedia/taglib 1.13.1 |
| desktop/thunderbird | 153.5.1 | mail/thunderbird 159.0 |
| gnome/totem | 43.1 | multimedia/totem 42.0 |
| gnome/totem-pl-parser | 3.26.6 | multimedia/totem-pl-parser 3.26.6 |
| gnome/tracker | 2.3.6 | desktop/tracker 1.8.3 |
| gnome/tracker-miners | 2.3.5 | **missing** |
| desktop/upower | 1.90.4 | sysutils/upower 0.99.11 |
| gnome/vala | 0.56.18 | developer/vala 0.56.19 |
| gnome/vte | 0.66.0 | library/vte-291 0.84.1 |
| desktop/xdg-utils | 1.2.1 | desktop/xdg-utils 1.2.1 |
| gnome/yelp-tools | 42.1 | desktop/gnome/yelp-tools 42.1 |
| gnome/yelp-xsl | 42.1 | desktop/gnome/yelp-xsl 49.0 |
| gnome/zenity | 3.41.0 | desktop/gnome/zenity 3.44.5 |
