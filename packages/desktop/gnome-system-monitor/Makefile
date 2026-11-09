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

# gnome-system-monitor 42.0, the last GTK3 release (43+ need gtkmm-4.0,
# which OpenIndiana does not have): gtkmm-3.0, libhandy and libgtop, all in
# OI.  Solaris 11.4 does not ship it.  No systemd, no wnck.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-system-monitor
HUMAN_VERSION=		42.0
COMPONENT_SUMMARY=	GNOME System Monitor - process viewer and system monitor
COMPONENT_PROJECT_URL=	https://wiki.gnome.org/Apps/SystemMonitor
COMPONENT_ARCHIVE_HASH=	\
	sha256:13239d22032201a22bd29833c575b684816700d2de168a1530223577c5c075dc
COMPONENT_FMRI=		desktop/system-monitor/gnome-system-monitor
COMPONENT_CLASSIFICATION=	Applications/System Utilities
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/gnome-system-monitor/42/gnome-system-monitor-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
CXXFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
# getnameinfo() (open files view) is in libsocket on illumos
LDFLAGS +=		-lsocket -lnsl

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dsystemd=false
CONFIGURE_OPTIONS +=	-Dwnck=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += text/itstool
REQUIRED_PACKAGES += library/c++/glibmm
REQUIRED_PACKAGES += library/desktop/c++/gtkmm3
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/libhandy
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/libgtop
REQUIRED_PACKAGES += library/libxml2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += $(GXX_RUNTIME_PKG)
REQUIRED_PACKAGES += $(GCC_RUNTIME_PKG)
REQUIRED_PACKAGES += image/library/librsvg
REQUIRED_PACKAGES += library/c++/sigcpp
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += system/library/math
