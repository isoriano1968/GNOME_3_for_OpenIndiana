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

# GNOME Calculator 47.3 (Solaris 11.4: 41.0, GTK3). GNOME 47 release on GTK
# 4 and libadwaita 1.6, written in Vala (OI's vala 0.56), with libgee, mpfr,
# mpc and libsoup-3 (currency rates) from OI. The GCalc/GCi libraries are
# installed too (the app uses them).

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-calculator
HUMAN_VERSION=		47.3
COMPONENT_SUMMARY=	GNOME Calculator
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/gnome-calculator
COMPONENT_ARCHIVE_HASH=	\
	sha256:e6ebdf3400f5818cf4aa207e1b011e61314bb64ceb81690a0b0c028a2b14fa9a
COMPONENT_FMRI=		desktop/calculator/gnome-calculator
COMPONENT_CLASSIFICATION=	Applications/Accessories
COMPONENT_LICENSE=	GPL-3.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/gnome-calculator/47/gnome-calculator-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Ddoc=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += developer/vala
REQUIRED_PACKAGES += library/desktop/gobject/gobject-introspection
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/gtksourceview-5
REQUIRED_PACKAGES += library/desktop/libadwaita
REQUIRED_PACKAGES += library/desktop/libgee
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/libsoup3
REQUIRED_PACKAGES += library/libxml2
REQUIRED_PACKAGES += library/mpc
REQUIRED_PACKAGES += library/mpfr
REQUIRED_PACKAGES += system/library
