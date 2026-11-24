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

# GNOME Panel 3.50.0 (the panel of the GNOME Flashback session, and
# libgnome-panel for its applets), the GNOME 45 generation.
# patches/01-systemd-optional.patch: libsystemd only routes the output of
# started programs to the journal; it becomes optional, so the panel builds
# without systemd.  Calendar events in the clock (evolution-data-server) are
# off for now; the man pages too (no docbook tool chain needed).

BUILD_BITS=		64
BUILD_STYLE=		configure

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-panel
HUMAN_VERSION=		3.50.0
COMPONENT_SUMMARY=	GNOME Panel, the panel of GNOME Flashback
COMPONENT_ARCHIVE_HASH=	\
	sha256:025ec889d04262d41c95bee85be6421ba3a6050e269b9ce99f692cad49a2eb13
COMPONENT_FMRI=		gnome/gnome-panel
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	GPL-2.0-or-later AND LGPL-2.1-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

# illumos: the strict standard mode hides stack_t etc. that system headers
# (libgtop's procfs, kvm) need; -D_REENTRANT for GLib's per-thread errno
CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS -D_REENTRANT

# the patch changes configure.ac and Makefile.am files
COMPONENT_PREP_ACTION +=	(cd $(@D) && PATH="$(PATH)" $(AUTORECONF) -fi) ;

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"
CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	--disable-static
CONFIGURE_OPTIONS +=	--without-systemd
CONFIGURE_OPTIONS +=	--disable-eds
CONFIGURE_OPTIONS +=	--disable-documentation
# Auto-generated dependencies
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += gnome/config/dconf
REQUIRED_PACKAGES += gnome/gnome-menus
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/geocode-glib-2
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/desktop/libgdm
REQUIRED_PACKAGES += library/desktop/libgweather
REQUIRED_PACKAGES += library/desktop/libwnck
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += system/library/polkit
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxrandr
