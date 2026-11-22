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

# xdg-desktop-portal 1.22.1, the D-Bus frontend that Chromium, Electron and
# other applications use for the desktop's own file dialogs
# (org.freedesktop.portal.FileChooser). Built as FreeBSD's deskutils/xdg-
# desktop-portal: no systemd, no Flatpak interfaces, no bubblewrap sandbox
# for icon and sound validation. OpenIndiana has neither FUSE 3 nor
# PipeWire, so the document portal and the camera, screen cast, remote
# desktop and clipboard portals are left out (patches/01). Started by D-Bus
# session activation.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		xdg-desktop-portal
HUMAN_VERSION=		1.22.1
COMPONENT_REVISION=	2
COMPONENT_SUMMARY=	xdg-desktop-portal - desktop integration portal frontend for applications
COMPONENT_PROJECT_URL=	https://github.com/flatpak/xdg-desktop-portal
COMPONENT_ARCHIVE_HASH=	\
	sha256:d4879ddb3d65ff1a8f19187497e6f13dc5d267bcac404a5d501218be355753d3
COMPONENT_FMRI=		library/desktop/xdg/xdg-desktop-portal
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Libraries
COMPONENT_LICENSE=	LGPL-2.1-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://github.com/flatpak/xdg-desktop-portal/releases/download/$(HUMAN_VERSION)/$(COMPONENT_NAME)-$(HUMAN_VERSION).tar.xz

# libglnx: the release bundles GNOME's Linux-only libglnx; FreeBSD's port uses
# Gleb Popov's (arrowd) BSD port of it, and so do we (illumos changes in
# patches/04).  Unpacked over subprojects/libglnx before the patches.
LIBGLNX_COMMIT=		c210033e145361b5f5125d79dff4f901c01aa3f7
COMPONENT_ARCHIVE_1=	libglnx-$(LIBGLNX_COMMIT).tar.gz
COMPONENT_ARCHIVE_HASH_1=	\
	sha256:4fdc4bf83d63ef80e05f2528f7f17f7eb51580da5910bf72bb0e3475c2c0bb61
COMPONENT_ARCHIVE_URL_1=	https://gitlab.gnome.org/arrowd/libglnx/-/archive/$(LIBGLNX_COMMIT)/$(COMPONENT_ARCHIVE_1)
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
# Threaded: without _REENTRANT, illumos' errno is one global variable and
# another thread's failed call overwrites it (rev 1 refused every portal
# call: an ENOENT for /proc/PID/cgroup read back as ENOTTY).
CFLAGS +=		-D_REENTRANT

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Ddocument-portal=disabled
CONFIGURE_OPTIONS +=	-Dpipewire=disabled
CONFIGURE_OPTIONS +=	-Dsystemd=disabled
CONFIGURE_OPTIONS +=	-Dflatpak-interfaces=disabled
CONFIGURE_OPTIONS +=	-Dsandboxed-image-validation=disabled
CONFIGURE_OPTIONS +=	-Dsandboxed-sound-validation=disabled
CONFIGURE_OPTIONS +=	-Dgeoclue=disabled
CONFIGURE_OPTIONS +=	-Dgudev=disabled
CONFIGURE_OPTIONS +=	-Ddocumentation=disabled
CONFIGURE_OPTIONS +=	-Dman-pages=disabled
CONFIGURE_OPTIONS +=	-Dtests=disabled
CONFIGURE_OPTIONS +=	-Dinstalled-tests=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

COMPONENT_POST_UNPACK_ACTION += \
	$(RM) -r $(SOURCE_DIR)/subprojects/libglnx ; \
	$(GTAR) -xzf $(USERLAND_ARCHIVES)$(COMPONENT_ARCHIVE_1) \
	    -C $(SOURCE_DIR)/subprojects ; \
	$(MV) $(SOURCE_DIR)/subprojects/libglnx-$(LIBGLNX_COMMIT) \
	    $(SOURCE_DIR)/subprojects/libglnx ;

# No systemd: D-Bus session activation starts the portal
# (org.freedesktop.portal.Desktop.service), so the user units are not shipped.
COMPONENT_POST_INSTALL_ACTION += \
	$(RM) -r $(PROTO_DIR)$(USRLIBDIR)/systemd ;

REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/desktop/json-glib
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/audio/gstreamer
REQUIRED_PACKAGES += library/audio/gstreamer/plugin/base
REQUIRED_PACKAGES += system/library
