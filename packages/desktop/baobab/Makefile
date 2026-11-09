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

# baobab (Disk Usage Analyzer) 47.0, GNOME 47 release on GTK 4 and
# libadwaita 1.6, written in Vala (OI's vala 0.56).

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		baobab
HUMAN_VERSION=		47.0
COMPONENT_SUMMARY=	Disk Usage Analyzer for GNOME
COMPONENT_PROJECT_URL=	https://apps.gnome.org/Baobab/
COMPONENT_ARCHIVE_HASH=	\
	sha256:b88f74f9c052d3c2388f7062d228cf5e927545acf7408c56841df80ccd1f9c37
COMPONENT_FMRI=		gnome/disk-analyzer/baobab
COMPONENT_CLASSIFICATION=	Applications/System Utilities
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/baobab/47/baobab-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += developer/vala
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/libadwaita
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/graphene
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += system/library/math
