#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#

#
# Copyright 2026 isoriano1968
#

# mutter 45.7 as in Solaris 11.4 (solaris-userland components/gnome/mutter
# @9d7a655): X11 compositing window manager only (no native/Wayland backend,
# no udev, libwacom, remote desktop, libei), with Solaris' patches
# (12-37245012 is i386-only on Solaris; OI is i386-only).
# Solaris' -Wl,-zgnu-version-script-compat does not exist in illumos ld.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		mutter
HUMAN_VERSION=		45.7
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/mutter
COMPONENT_SUMMARY=	mutter - GNOME window manager and compositor
COMPONENT_ARCHIVE_HASH=	\
	sha256:5fa01a100c468efa1ddc232cb3c91865d092760946e3e3c61b2b6cd31f000968
COMPONENT_FMRI=		gnome/window-manager/mutter
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Window Managers
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-Wno-incompatible-pointer-types
CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dnative_backend=false
CONFIGURE_OPTIONS +=	-Dsystemd=false
CONFIGURE_OPTIONS +=	-Dwayland=false
CONFIGURE_OPTIONS +=	-Dxwayland=false
CONFIGURE_OPTIONS +=	-Dwayland_eglstream=false
CONFIGURE_OPTIONS +=	-Dxwayland_path=''
CONFIGURE_OPTIONS +=	-Dudev=false
CONFIGURE_OPTIONS +=	-Dlibwacom=false
CONFIGURE_OPTIONS +=	-Dprofiler=false
CONFIGURE_OPTIONS +=	-Dremote_desktop=false
CONFIGURE_OPTIONS +=	-Dtests=false
CONFIGURE_OPTIONS +=	-Dintrospection=true
CONFIGURE_OPTIONS +=	--wrap-mode=nofallback

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += library/desktop/gobject/gobject-introspection
REQUIRED_PACKAGES += gnome/config/gsettings-desktop-schemas
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/graphene
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/json-glib
REQUIRED_PACKAGES += library/desktop/startup-notification
REQUIRED_PACKAGES += library/desktop/xdg/libcanberra
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/lcms2
REQUIRED_PACKAGES += service/image/colord
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libxcvt
REQUIRED_PACKAGES += x11/library/libxkbcommon
REQUIRED_PACKAGES += x11/library/mesa
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += library/c++/harfbuzz
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += library/fribidi
REQUIRED_PACKAGES += system/library/fontconfig
REQUIRED_PACKAGES += x11/library/libice
REQUIRED_PACKAGES += x11/library/libsm
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxcb
REQUIRED_PACKAGES += x11/library/libxcomposite
REQUIRED_PACKAGES += x11/library/libxcursor
REQUIRED_PACKAGES += x11/library/libxdamage
REQUIRED_PACKAGES += x11/library/libxext
REQUIRED_PACKAGES += x11/library/libxfixes
REQUIRED_PACKAGES += x11/library/libxi
REQUIRED_PACKAGES += x11/library/libxinerama
REQUIRED_PACKAGES += x11/library/libxkbfile
REQUIRED_PACKAGES += x11/library/libxrandr
REQUIRED_PACKAGES += x11/library/libxtst
