# GNOME 3 on OpenIndiana SPARC (Ultra 45), software GL: analysis

Started 2026-11-23. Target: the x86 OI GNOME 45 stack (docs/gnome3-port.md,
`packages/`) on OpenIndiana SPARC, X11 session, Mesa softpipe now, llvmpipe
later. Hardware GL (radeon DRM, r300) is separate work.

Sources: the OI SPARC package repository's PACKAGES.txt (5308 entries,
2026-11-23) and package manifests, oracle/solaris-userland master
(2026-11-23), the illumos-gate SPARC tree (3dbb2c16a0). "Present" below
means "in the OI SPARC repository".

## 1. The stack, and what OI SPARC has

### Present on SPARC, same version as x86 OI (reuse as is)

glib 2.86.5 (+32), gobject-introspection 1.86.0, gtk3 3.24.52, gtk4 4.16.13,
libadwaita 1.6.10, libhandy 1.8.3, pango 1.58.0, cairo 1.18.6, harfbuzz 15.1.0,
gdk-pixbuf 2.44.8, librsvg 2.61.4 (Rust, so Rust works for libraries),
at-spi2-core 2.62.1, json-glib 1.10.6, graphene 1.10.8, libsoup3 3.6.4,
gcr 3.41 + gcr-4 4.4.0.1, gnome-keyring 46.2, libsecret 0.21.7,
gnome-desktop 44.4, gsettings-desktop-schemas 50.1, dconf 0.40, adwaita-icon-
theme 50.0, gnome-themes-extra, libnotify, libcanberra, startup-notification,
libxkbcommon 1.13.2, libepoxy 1.5.10, lcms2, libical 3.0.20, geocode-glib
3.26.4 (soup2 flavour), libgtop, gtksourceview-5, vte-291 0.82.3, libpeas-2,
ibus 1.5.29, ConsoleKit 0.4.6 (+ pam-consolekit), upower 0.99.11, dbus 1.16.2,
pulseaudio 17.0, gstreamer 1.28.9, avahi, nss/nspr, icu-79, cups-libs,
webkitgtk 2.52.6 (JavaScriptCore builds on big-endian SPARC).
Build tools: meson 1.7.2, ninja 1.13.2, cmake 4.5, vala 0.56, sassc, gperf,
itstool, rustc 1.95 (native target `sparcv9-unknown-illumos`), cargo-c,
cbindgen, clang/LLVM 18-21 (LLVM 21 has the Sparc backend), Python 3.9, 3.14,
3.15, gcc 13.4 (no gcc 14), GNU binutils 2.46.
X/GL: Xorg 1.19.7, Mesa 21.3.9 (rev 7 carries Oracle's
big-endian patches; softpipe, GL 3.3, EGL + GBM libraries present),
libdrm 2.4.109, LightDM 1.30, GDM 2.30.7 (GNOME 2 era).

### Missing on SPARC (all are our x86 components, except where noted)

| Component | x86 version | SPARC risk |
|---|---|---|
| duktape | 2.7.0 | none (portable C, endian-aware) |
| polkit | 125 (duktape engine) | low: no mozjs needed with duktape |
| accountsservice | 0.6.55 | low |
| colord, colord-gtk | 1.4.7, 0.3.1 | low (ICC byte order handled by lcms2) |
| geoclue | 2.7.2 | low |
| geocode-glib-2, libgweather | 3.26.4, 4.4.4 | low |
| gsound | 1.0.3 | none |
| evolution-data-server | 3.50.3 | medium: big C build, long on the U45 |
| **mozjs-140** (oi-userland, not ours) | 140.x | **high** (section 2) |
| **gjs** (oi-userland, not ours) | 1.90 | high, follows mozjs |
| mutter | 45.7 (X11 only) | medium: big-endian pixel formats in cogl; speed |
| gnome-shell | 45.9 | medium: needs gjs; speed |
| gnome-session, gnome-settings-daemon | 45.0, 45.1 | low |
| gdm + libgdm | 45.0.1 | medium: VT/ConsoleKit (same as x86) |
| gnome-control-center | 41.7 | low |
| cantarell, adwaita-fonts, gnome-backgrounds, shell-extensions | | none |
| tinysparql, libportal, gnome-autoar (apps) | | low |
| pygobject for Python 3.14 | | low (only 3.9 exists; needed by tweaks, not by the shell) |

Not needed (as on x86 and Solaris): Wayland, pipewire (screencast off),
systemd/elogind (ConsoleKit), udev/libinput, NetworkManager, libei.

## 2. What really blocks on SPARC

1. **SpiderMonkey on 64-bit SPARC: the 47-bit pointer limit.** mozjs packs
   pointers into NaN-boxed values and needs every GC pointer below 2^47. On
   64-bit Solaris/illumos SPARC, mmap and the stack sit near the top of the
   address space (0xffffffff7f...). Oracle solves this with a linker mapfile
   `RESERVE_SEGMENT spidermonkey_reserve { VADDR=0x800000000000; ... }` in
   every program that loads libmozjs (gjs-console, gnome-shell, polkitd;
   patches gjs/01-mozjs-workaround.sparc, gnome-shell/08_VM.sparc).
   **illumos ld has no RESERVE_SEGMENT** (not in usr/src/cmd/sgs), so that
   route is closed without a linker + kernel change. A GC-allocator-only fix
   is not enough either; the illumos fix is the ADDR32 capability, see 2a.
2. **mozjs build on SPARC:** Rust target name (Mozilla's rust.configure
   expects `sparcv9-sun-solaris`, OI SPARC's rustc is `sparcv9-unknown-illumos`),
   Oracle's 02-sparc.patch (config.guess, 28 lines), no JIT on SPARC (the
   interpreter only; fine), the .eh_frame trouble the OI SPARC Rust notes describe between
   gcc 13 + illumos ld and Rust objects (librsvg and cargo-c build, so there
   is a working recipe in the OI SPARC oi-userland to copy). Build time on two 1.6 GHz
   cores: roughly a day; longest single build of the stack.
3. **Speed of software GL.** softpipe here draws shadercube at about 1
   frame/s at 512x512. gnome-shell composites the whole 1920x1200 screen
   through GL every frame; on softpipe that will be a slide show. A usable
   shell needs llvmpipe, which needs (a) a Mesa new enough for LLVM 21
   (Mesa 21.3 supports LLVM up to about 15), i.e. the Mesa 26 of the shared
   stack plan, and (b) SPARC relocations in LLVM's RuntimeDyld (MCJIT):
   Oracle carries them for LLVM 13 (llvm-13/033-solaris-LLVM-JIT.patch,
   "gnome-shell cores dump on sparc ... without this"). They must be ported
   to the LLVM 21 that Mesa uses: a change to the SPARC clang/LLVM package,
   together with the Mesa 26 work.
   GTK 4 apps also render through GL by default; same speed issue.
4. **gcc 13 only**: our x86 Makefiles assume gcc 14 in places; set per
   component, no SPARC hacks.
5. **Big-endian in mutter/cogl**: pixel format tables and XImage paths.
   Debian runs GNOME Shell on s390x/ppc64 (big-endian), so upstream is
   mostly right; test colours on the real screen, not only by readback
   (the ati colour bug was invisible to xwd).
6. **Build machine**: the U45 is slow and shared with driver work.
   The T4-2 (128 threads) is the natural build box for mozjs, e-d-s, mutter
   and the shell (build for plain sparcv9, no T4-only instructions, so the
   binaries run on the US-IIIi). Not in use at present.

## 2a. mozjs-140 on illumos sparcv9: source analysis (2026-11-23, off the box)

Source: firefox-140.17.0esr.source.tar.xz, sha256 4d6ed3b1...05c33 (the same
archive and hash as oi-userland's components/library/mozjs-140 recipe).

**The 47-bit rule is wider than the GC heap.** js/public/Value.h:
`IsValidUserModePointer()` requires the top 16 bits of *every* pointer stored
in a Value to be zero, and `setPrivate()` stores raw pointers (143
`PrivateValue(` call sites in js/src, more in gjs). So not only GC chunks
but any pointer into a shared library's data, a thread stack or an
mmap'd buffer must be below 2^47. On illumos sparcv9 all of those live
just under USERLIMIT 0xFFFFFFFF80000000 (sun4u machparam.h). Release
builds do not assert; a high pointer is silently read as a tagged value
and the process crashes later. That is why Oracle reserves the whole high
address range for the process, not just the GC heap.

The GC allocator itself (js/src/gc/Memory.cpp) has changed since Oracle's
and Linux's old sparc64 fixes: it probes the address limit at run time
(`FindAddressLimit`), clamps to 47 bits and uses a random "scattershot"
allocator. On sun4u that would mostly work (hints in the VA hole above
2^43 fail and are retried), but it does not help with the non-GC pointers
above. So patching Memory.cpp alone is **not** the fix.

**Fix at the cause, with stock illumos: the SF1_SUNW_ADDR32 capability.**
A 64-bit executable tagged ADDR32 gets `a_userlimit = USERLIMIT32`
(0xFFC00000) and its stack at USRSTACK64_32 (uts/common/os/exec.c 2028,
2198; elf.c 587). Every mapping, library, thread stack and malloc pointer
of the process is then below 4 GB, so all Values are valid, and
Memory.cpp's probe finds 32 address bits and uses its plain path. The
linker supports it in a v2 mapfile (`CAPABILITY { SF += ADDR32; };`) and
then links the text at the low origin by itself (sgs machdep_sparc.h); the
runtime linker loads ordinary libraries into such a process (rtld cap.c,
setup.c). This is the illumos counterpart of Oracle's RESERVE_SEGMENT, on
the same executables:
- `gjs-console` (gjs; Oracle: gjs/01-mozjs-workaround.sparc),
- `gnome-shell` (Oracle: gnome-shell/08_VM.sparc),
- any other program that loads libmozjs. polkitd does not: ours uses
  duktape. libpeas' gjs loader must stay off on SPARC (gedit etc. are not
  ADDR32).
Limit: 4 GB of address space for gnome-shell; normal use is well below.
No run-time guard is needed: **libmozjs itself is tagged ADDR32.** The
runtime linker then refuses it in any process not started as ADDR32
(rtld cap.c `sfcap1_check`), and ld warns when an untagged executable
links against it (libld.msg MSG_FIL_EXADDR32SF1). A forgotten tag shows up
as a clear load error, never as random crashes. The tag goes only on the
final links (libmozjs, the js shell), not into LD_OPTIONS: Rust
proc-macro libraries tagged ADDR32 would be refused by rustc itself.

**Build configuration on SPARC** (the oi-userland recipe is x86-only):
- CPU/OS: configure maps `sparcv9-*` to sparc64 and, with oi-userland's
  existing `moz.configure_add_illumos.patch`, `illumos` to SunOS. Use
  `--host/--target=sparcv9-unknown-illumos` (recipe has GNU_ARCH
  x86_64-unknown-illumos hard-coded).
- Rust: the recipe downloads rustup + Rust 1.86 for x86 (rustup has no
  sparcv9 illumos build). Use the system rustc 1.95 (native target
  `sparcv9-unknown-illumos`; configure narrows its candidates by raw OS
  "illumos" and picks it over `sparcv9-sun-solaris`) and system cbindgen
  0.29.4. Rust 1.95 against ESR 140: probably fine, check in configure.
- JIT: none on sparc64 (JS_CODEGEN_NONE, interpreter only); set
  `--disable-jit` explicitly. Atomics: the gcc `__atomic` builtins path
  (AtomicOperations-feeling-lucky-gcc.h, has sparc). Wasm signal handlers
  already have a `__sun__ && __sparc__` register set.
- Recipe parts to make per-architecture: `PKG_CONFIG=/usr/bin/amd64/
  pkg-config`, `-msave-args` (x86-only gcc flag), the rustup block,
  `runtime/nodejs-24` (absent on SPARC; a js-only build should not need
  it: check), `gnome/config/gconf`, `web/browser/lynx` (Firefox leftovers).
- All other build dependencies exist on SPARC: autoconf-213, http-parser,
  libffi 3.2.1, nspr 4.40, readline, psutil, sqlite, pulseaudio headers.
- Linker trouble to expect: OI SPARC's README.rust says gcc 13 + illumos ld
  disagree with Rust objects over `.eh_frame` flags; libjsrust.a is
  linked into libmozjs by gcc. librsvg/cargo-c build on SPARC, so the OI
  SPARC oi-userland has a working answer: read his recipes before the build.
- Build time: one long build on the U45 (estimate a day at -j2, nice).
  Restartable (gmake, logs on disk); the box may reboot for driver tests.

## 2b. mozjs-140 SPARC recipe (2026-11-23, not built yet)

`packages/library/mozjs-140`: oi-userland's recipe at d87ae8ac6, SPARC-only
in this repo (x86 keeps OI's package):
- `patches/10-sparc-addr32.patch` (new): js/src/build/sparc-addr32.mapfile
  (`CAPABILITY { SF += ADDR32; };`), added to the libmozjs link in
  js/src/build/moz.build and the js shell link in js/src/shell/moz.build,
  both only for TARGET_CPU sparc64 on SunOS. Header explains why, links
  Mozilla bug 577056. Mapfile keywords checked against illumos libld
  (map_v2.c `SF`/`SF_1`, elfcap `ADDR32`; comments before
  `$mapfile_version` are allowed).
- `Makefile`, all SPARC parts conditional, x86 expansion identical to
  upstream (checked with GNU make against stub make-rules):
  - gcc 13 on sparc (set before shared-macros.mk, as x11/mesa does);
  - GNU_ARCH per MACH: sparcv9-unknown-illumos;
  - pkg-config `/usr/bin/$(MACH64)/pkg-config` (OI SPARC's pkg-config has
    /usr/bin/sparcv9/pkg-config);
  - `--disable-jit` on sparc;
  - `-msave-args` and the rustup/cargo-install block only on i386; SPARC
    uses the system rustc 1.95 and cbindgen 0.29.4;
  - `AR=/usr/bin/ar`, `STRIP=/usr/bin/strip` on sparc: GNU ar dies with
    SIGBUS there (x11/mesa), and GNU strip might drop the capabilities
    section that carries ADDR32;
  - nodejs-24 and header-audio build deps only on i386 (a js-only build
    does not include node.configure; header-audio does not exist on
    SPARC); developer/rust/cbindgen added on sparc.
- The full patch series applies to the pristine 140.17.0esr source (the
  older x86 patches with fuzz/offsets, as upstream).
- libffi 3.2.1 on SPARC meets configure's `libffi > 3.0.9`.

Still to do, on the box, before/at the build (oi-userland tooling, no
hand-made files): `env - gmake refresh-patches`, `gmake REQUIRED_PACKAGES`
(sparc runtime deps), `gmake update-metadata` (pkg5), then after the
build `gmake sample-manifest` and compare with mozjs-140.p5m (the header
set may differ without JIT). Checks after the build: `elfdump -H` shows
ADDR32 on libmozjs-140.so and js140; `js140 -e 'print(1)'`; a GC stress
script; an untagged test program must fail to load libmozjs with the
capability error.
Watch items: the Rust `.eh_frame` link issue (the SPARC librsvg recipe needs
nothing special, so probably fine); Rust 1.95 vs ESR 140 crates; the
`browser/installer` post-build step from upstream.
Next component: gjs 1.90 with ADDR32 on gjs-console and its test programs.

### ADDR32 proven on the U45 (2026-11-23)

Tiny user-level test in its own /tmp directory, gcc 13 -m64 + illumos ld,
nice 19, removed afterwards. A shared object linked with the mapfile
`CAPABILITY { SF += ADDR32; };`:
- linking an untagged executable against it: `ld: warning: file
  ./libt32.so: section [1].SUNW_cap: software capability ADDR32: requires
  executable be built with ADDR32 capability`;
- running that executable: `ld.so.1: main_untagged: fatal: ./libt32.so:
  software capability (CA_SUNW_SF_1) unsupported: 0x4 [ ADDR32 ]`, killed
  at start;
- dlopen() from an untagged program: refused with the same message
  (dlerror); an untagged copy of the library loads;
- a tagged executable loads it, and pmap shows everything below 4 GB: text
  0x100000, heap 0x202000, mmap 0xEE400000, libc 0xEE800000, the library
  0xEEC00000, ld.so.1 0xEF200000, stack 0xFFBFC000.
So the enforcement is real, and no JS_Init guard is needed.

## 3. Order and milestones (proposal)

- **M1, services layer under MATE** (small, low risk, days): duktape →
  polkit → accountsservice → colord, colord-gtk → geocode-glib-2 →
  libgweather → geoclue → gsound. Tested in a new test BE
  with MATE still the session (pkexec, gdbus calls).
- **Spike, in parallel from day one: mozjs-140 + gjs 1.90** (the long pole
  and the biggest risk). Source analysis first (47-bit allocator, Rust
  target, Oracle patch), one build, then `gjs -c` tests incl. GC stress.
- **M2, mutter 45 X11 on softpipe**: `mutter --replace` inside the MATE
  session in the test BE. Measures compositing speed and colours on the
  XVR-300. Decides whether the shell on softpipe is worth showing before
  llvmpipe.
- **M3, GNOME Shell session**: e-d-s, gnome-shell, gnome-session,
  gnome-settings-daemon, fonts/backgrounds; session started from the
  existing GDM 2.30.7 (or LightDM) via an xsession file. Careful: on
  the MATE desktop `gnome.desktop` is a MATE alias; the test BE must handle that
  in a package, not by hand.
- **M4**: gdm 45, gnome-control-center, extensions, apps (nautilus, terminal,
  text editor, eog, evince).
- **Parallel track with the driver work**: llvmpipe = Mesa 26 + LLVM 21
  RuntimeDyld SPARC port. Without it M3 works but is very slow.

A cheaper interim, if M2 shows softpipe is hopeless: GNOME Flashback
(gnome-panel + metacity, no GL compositor, no mozjs) on the same
gnome-session/g-s-d/services layer. Real GNOME 3 components, usable on the
U45 today; not the GNOME Shell look.

## 4. Rules for the builds

Pristine source + patches in `packages/`, oi-userland style, one package per
component, new revision per build, published to a local test repository and
installed only into new test BEs; builds with nice.

## 2c. Whole stack made SPARC-ready, off the box (2026-11-23)

Waits for hardware GL (radeon) before anything is built or installed.
Rule: x86 GNOME 3 must not change.

- Our 22 GNOME recipes need no SPARC edits: all arch-neutral (BUILD_BITS
  64, `$(MACH64)`, gcc runtime via macros). gcc 13 is passed by
  tools/u45-build.sh as `GCC_VERSION=13` on the gmake command line.
- SPARC-only patches use Oracle's convention: `patches/*.sparc` are not
  picked up by oi-userland's `*.patch*` wildcard; the Makefile adds them
  with `ifeq ($(MACH),sparc) ADDITIONAL_PATCHES += ...`. Checked with GNU
  make: empty on i386, the patch on sparc.
  - desktop/gnome-shell `30-sparc-addr32.sparc`: gnome-shell and
    run-js-test linked with the ADDR32 mapfile (meson condition
    `host_machine.system() == 'sunos' and cpu_family() == 'sparc64'`;
    meson maps sun4u/sun4v to sparc64).
  - desktop/mutter `30-sparc-gsk-renderer.sparc`: puts upstream's
    GSK_RENDERER=cairo back in mutter-x11-frames on SPARC, as Oracle
    applies 12-37245012 on i386 only ("rendering and performance issues on
    sparc").
- library/gjs (new, SPARC-only copy of OI's 1.90.1 recipe, i386 `$(error)`
  guard like mozjs-140): `20-sparc-addr32.sparc` tags gjs-console,
  gjs-tests, gjs-tests-internal and minijasmine.
- All series dry-applied on the pristine sources with the existing patches
  first (no fuzz); edited meson files parsed with meson 1.7's parser.
- Big-endian read (mutter 45.7, gnome-shell 45.9, g-s-d 45.1): no patch
  needed. Cairo ARGB32 is mapped by G_BYTE_ORDER (clutter-cairo.h,
  xcursor); X11 texture-from-pixmap takes the format from the visual masks
  and the XImage byte_order (cogl-util.c), so it is right whatever byte
  order the server reports (relevant: the SPARC xorg-server.h says
  little-endian); screenshot and icon code work on native uint32 / byte
  RGBA. g-s-d plugins have no hand-made pixel shifts. Colour still to be
  checked by eye on the XVR-300.
- Build order: tools/gnome3-sparc.order (from the components'
  REQUIRED_PACKAGES). gdm <-> gnome-shell is only a run-time cycle: build
  gdm first, install library/desktop/libgdm, install gdm after the shell.
  Not for SPARC: our library/gtk4 (needs Mesa 26 EGL).
- Open: where build tools and our packages go on the build box (plan: a
  separate build BE, `pkg -R` installs, chroot build).

### solaris-userland SPARC sweep (2026-11-23, master)

All `*.sparc` patches and `sparc` Makefile branches of the components we
port, compared with ours:
- ADDR32/47-bit: Oracle tags gjs, gnome-shell, polkit and the mozjs shell
  executables with `/usr/lib/ld/map.vas47` (RESERVE_SEGMENT), and Firefox
  tags firefox and js/src/shell in moz.build under `OS_ARCH SunOS` and
  `TARGET_CPU sparc64`: the same places and condition as our ADDR32 patches.
  Oracle uses LD_EXEC_OPTIONS.64 (every executable of the component); ours
  names the programs that link libgjs/libmozjs. polkit: n/a (duktape).
- mozjs-140 02-sparc.patch (config.guess: detect a 64-bit SPARC build
  machine): not needed, our recipe passes --host/--target
  sparcv9-unknown-illumos, so config.guess is not consulted.
- evolution-data-server: -DENABLE_GTK_DOC=OFF ("might crash on sparc"):
  ours has it.
- REQUIRED_PACKAGES.sparc += system/library/math (gjs, e-d-s, upower):
  comes from `gmake REQUIRED_PACKAGES` on the box.
- glib2 `ulimit -n 16384` (ninja "Too many open files" on sparc): glib is
  the repository's; keep in mind if a big meson build hits it.
- nautilus.p5m.sparc: 32-bit SPARC binaries in Oracle's old layout; n/a.
- Others are outside GNOME: firefox (webrender off, freebl, nspr asm),
  libvpx decode fix, python fpstructs, Xorg/Xvnc/ast/mga, Mesa llvmpipe
  (05-llvmpipe-nir-sparc, with LLVM's 033-solaris-LLVM-JIT for llvmpipe).

## 5. llvmpipe on SPARC: LLVM 21 JIT analysis (2026-11-23)

Question: can Mesa's llvmpipe (and gallivm, which r300 also uses for
vertex shaders) run on sparcv9 with LLVM 21?

- gallivm compiles shaders at run time with **MCJIT**, which loads the
  generated ELF object through **RuntimeDyld** (`RuntimeDyldELF`). Mesa's
  optional ORC path (`-Dllvm-orcjit`) also needs an object linker
  (RuntimeDyld or JITLink).
- LLVM 21.1.0 `RuntimeDyldELF.cpp` handles aarch64, arm, bpf, loongarch64,
  mips, ppc, riscv, systemz and x86 only: **no Sparc**, so every SPARC
  relocation hits the default case. JITLink has no Sparc backend either.
  The Sparc *code generator* is complete (Oracle builds llvm-21 with
  `LLVM_TARGETS_TO_BUILD=Sparc`). Only the run-time linker part is missing.
- Oracle's fix: `components/llvm-13/patches/033-solaris-LLVM-JIT.patch`
  (633 added lines in 10 hunks): SPARC relocations in RuntimeDyldELF
  (`resolveSPARC64Relocation`, the stub/GOT handling), the missing
  R_SPARC_* numbers in Sparc.def, and the elf32-sparc32plus name. Its
  header: gnome-shell crashed on sparc when Mesa used LLVM without it.
  Oracle's **llvm-21 carries only two patches** (D35755-2, firefox) and
  no JIT patch. Oracle's Mesa (21.3.8) still uses llvm-13 for exactly
  this reason. Its `05-llvmpipe-nir-sparc.patch` (65 lines) is the Mesa
  side.
- So the work is: **port 033 to LLVM 21's RuntimeDyld** (the API moved
  since 13: `Expected<>` returns, `RelocationValueRef`, stub handling),
  in our llvm-21 recipe as a clean patch for both architectures (x86
  output unchanged: the code only runs for `Triple::sparcv9`). Then port
  Mesa's 05 patch to Mesa 26, and build Mesa with `gallium-drivers`
  including llvmpipe for SPARC, together with the SPARC driver work
  (one Mesa for x86 and SPARC).
- Tests: LLVM's own `ExecutionEngine/MCJIT` tests on sparcv9 (currently
  marked unsupported there), then Mesa `lp_test_*` (lp_test_arit,
  lp_test_blend, lp_test_conv, lp_test_format), then glxgears/shadercube
  under llvmpipe.
- Upstreamable: yes. A SPARC RuntimeDyld port is a missing feature, not
  a Solaris quirk, and helps Linux sparc64 too.

### gcc 14 on SPARC

solaris-userland has gcc14 (14.2.0), gcc15 and gcc16 building on SPARC.
gcc 14 on OI SPARC would let the x86 recipes keep their gcc 14 settings
and remove `GCC_VERSION=13` from tools/u45-build.sh. It is a long build
(bootstrap) on the U45: a T4-2 job.

## 6. C++ exceptions abort on OI SPARC (found 2026-11-24, FS-UAE test)

Symptom: every `throw` aborts in libgcc's `uw_init_context_1`, even a
five-line test program (-m64 and -m32, shared or static libgcc);
`_Unwind_Backtrace` aborts too. FS-UAE dies as soon as a 68040/060 MMU is
enabled (UAE raises MMU bus errors as C++ exceptions).

Cause, step by step:
1. illumos ld (osnet of January 2026, system/library
   0.5.11-2025.0.0.21764) refuses an unaligned `R_SPARC_DISP32`. gcc's own
   configure test, by hand: GNU as 2.46.1 `-K PIC` on
   `.data; .align 4; .byte 0; .uaword %r_disp32(foo)`, then `ld -G`:
   `ld: fatal: relocation error: R_SPARC_DISP32: file ua.o: symbol foo:
   offset 0xffffffff6e6005d1 is non-aligned` (32- and 64-bit alike; the
   offset printed is a host address, a cosmetic bug of its own).
2. gcc 13.4.0's configure test "unaligned pcrel relocs" therefore failed:
   auto-host.h has `/* #undef HAVE_AS_SPARC_UA_PCREL */`.
3. Without it gcc writes EH pointers as absptr / DW_EH_PE_aligned (0x50)
   instead of pcrel|sdata4.
4. For those FDEs illumos ld builds an `.eh_frame_hdr` whose search table
   has FdeCnt 0 (libgcc_s.so.1: FdeCnt 0; PT_SUNW_UNWIND p_memsz 0xc while
   the section is 0x18c).
5. libgcc (unwind-dw2-fde-dip.c) treats fde_count 0 as "no FDEs in this
   object", so no frame is ever found.

Reproducer: `g++ -m64 -O2` of `static void f(int x){ if (x) throw
std::runtime_error("x"); } int main(int c, char**){ try { f(c); } catch
(const std::exception&) { puts("caught"); } }` aborts (SIGABRT, stack:
abort < uw_init_context_1 < _Unwind_RaiseException < __cxa_throw);
`elfdump -u /usr/gcc/13/lib/sparcv9/libgcc_s.so.1` shows
`FdeCnt: 0` and the warning "file size does not match PT_SUNW_UNWIND
segment: sh_size=18c: p_filesz=c". Affected: gcc-13-runtime
13.4.0-2026.0.0.2 (the only version in the repository).

Fix at the cause: an osnet linker with illumos-gate 44a46dab27 (2026-11-20,
"Linker support unaligned DISP32/TLS DTPOFF relocations on SPARC"), then a
gcc built against it (configure then defines HAVE_AS_SPARC_UA_PCREL); our
gcc 14 for SPARC must be built that way and checked with a throw/catch
test and `elfdump -u libgcc_s.so.1` (FdeCnt > 0) before anything else.

