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

# GNOME Text Editor 47.4, GNOME's default editor since 42 (Solaris 11.4
# still ships gedit 41). GNOME 47 release: GTK 4.15+ and libadwaita 1.6,
# which OpenIndiana has, plus gtksourceview-5 (OI) and libspelling (our
# component). No .editorconfig support: it needs editorconfig-core-c, which
# OpenIndiana does not have.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-text-editor
HUMAN_VERSION=		47.4
COMPONENT_SUMMARY=	GNOME Text Editor
COMPONENT_PROJECT_URL=	https://gitlab.gnome.org/GNOME/gnome-text-editor
COMPONENT_ARCHIVE_HASH=	\
	sha256:3ac505a904aafce353813bb13a7b8f82a39d474c4a945ce89aef7e650ec9f8da
COMPONENT_FMRI=		editor/gnome-text-editor
COMPONENT_CLASSIFICATION=	Applications/Accessories
COMPONENT_LICENSE=	GPL-3.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

COMPONENT_ARCHIVE_URL=	https://download.gnome.org/sources/gnome-text-editor/47/gnome-text-editor-$(HUMAN_VERSION).tar.xz
include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Denchant=enabled
CONFIGURE_OPTIONS +=	-Deditorconfig=disabled

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/gtksourceview-5
REQUIRED_PACKAGES += library/desktop/libadwaita
REQUIRED_PACKAGES += library/desktop/libspelling
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += system/library/math
