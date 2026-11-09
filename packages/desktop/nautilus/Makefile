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

# Files (Nautilus) 47.6, GNOME 47 release on GTK 4 and libadwaita 1.6
# (Solaris 11.4: 3.34 on tracker 2). Needs TinySPARQL and libportal (our
# components), gexiv2 and gnome-autoar. No PackageKit, no cloudproviders, no
# SELinux, no tests. Search works without the localsearch indexer (left
# out).

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		nautilus
HUMAN_VERSION=		47.6
COMPONENT_SUMMARY=	Files (Nautilus) - GNOME file manager
COMPONENT_PROJECT_URL=	https://apps.gnome.org/Nautilus/
COMPONENT_ARCHIVE_HASH=	\
	sha256:cda3f3ef758c682259cec0be96bc6515c03ecd298b798073ad6f03b0faa7c710
COMPONENT_FMRI=		gnome/file-manager/nautilus
COMPONENT_CLASSIFICATION=	Applications/System Utilities
COMPONENT_LICENSE=	GPL-3.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/nautilus/47/nautilus-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dpackagekit=false
CONFIGURE_OPTIONS +=	-Dcloudproviders=false
CONFIGURE_OPTIONS +=	-Dselinux=false
CONFIGURE_OPTIONS +=	-Dtests=none
CONFIGURE_OPTIONS +=	-Ddocs=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += image/library/gexiv2
REQUIRED_PACKAGES += library/desktop/gnome-autoar
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/libadwaita
REQUIRED_PACKAGES += library/desktop/libportal
REQUIRED_PACKAGES += library/desktop/search/tinysparql
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += library/audio/gstreamer
REQUIRED_PACKAGES += library/audio/gstreamer/plugin/base
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/graphene
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += x11/library/libx11
