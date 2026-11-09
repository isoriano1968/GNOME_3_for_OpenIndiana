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

# gnome-terminal 3.60.0: GTK3 + libhandy + vte 0.84, matching OpenIndiana's
# vte-291 0.84.1 (Solaris 11.4 ships 3.41 on its older vte 0.66).  The
# terminal server is started by D-Bus session activation.  No Nautilus
# extension (no nautilus on OI yet), no docs.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-terminal
HUMAN_VERSION=		3.60.0
COMPONENT_SUMMARY=	GNOME Terminal - terminal emulator for GNOME
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/gnome-terminal
COMPONENT_ARCHIVE_HASH=	\
	sha256:b8daf3f08545172c4d2885733f720361ab0349ea669b99245eed4ad16ed3de28
COMPONENT_FMRI=		terminal/gnome-terminal
COMPONENT_CLASSIFICATION=	Applications/System Utilities
COMPONENT_LICENSE=	GPL-3.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/gnome-terminal/3.60/gnome-terminal-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
CXXFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
# socketpair() is in libsocket on illumos
LDFLAGS +=		-lsocket -lnsl

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dnautilus_extension=false
CONFIGURE_OPTIONS +=	-Dsearch_provider=true
CONFIGURE_OPTIONS +=	-Ddocs=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += text/itstool
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/libhandy
REQUIRED_PACKAGES += library/desktop/vte-291
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/pcre2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += $(GXX_RUNTIME_PKG)
REQUIRED_PACKAGES += $(GCC_RUNTIME_PKG)
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/pango
