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

# Dash to Dock v90 (extensions.gnome.org release 90, for GNOME Shell 45 and
# 46; v89 wraps 45.9's async _prepareStartupAnimation wrongly and the
# shell's startup animation throws), installed system-wide in
# /usr/share/gnome-shell/extensions, with its GSettings schema and
# translations in the system locations.  files/...gschema.override turns it
# on by default and keeps the dock always visible (dock-fixed).

BUILD_BITS=		NO_ARCH
BUILD_STYLE=		justmake

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		dash-to-dock
COMPONENT_VERSION=	90
COMPONENT_PROJECT_URL=	https://micheleg.github.io/dash-to-dock/
COMPONENT_SUMMARY=	Dash to Dock - GNOME Shell extension: the dash as a dock
COMPONENT_SRC=		dash-to-dock-extensions.gnome.org-v$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	\
	sha256:21fddef6db53796f09a38a2cdd583cfc694e1806114bc23a000ae4abebf6c1e3
COMPONENT_ARCHIVE_URL=	https://github.com/micheleg/dash-to-dock/archive/refs/tags/extensions.gnome.org-v$(COMPONENT_VERSION).tar.gz
COMPONENT_FMRI=		gnome/gnome-shell/extension/dash-to-dock
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Sessions
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/common.mk

# The upstream Makefile builds in the source tree and copies what it finds
# with cp -r: build in a real copy (cloney would leave symlinks behind).
COMPONENT_PRE_CONFIGURE_ACTION = ($(RM) -r $(@D) ; $(MKDIR) $(@D) ; $(CP) -rp $(SOURCE_DIR)/. $(@D))

# VERSION: otherwise the Makefile asks git for one.  DESTDIR selects the
# system-wide install (schemas and locale under /usr/share).
COMPONENT_BUILD_ARGS +=		VERSION=$(COMPONENT_VERSION) SASS=sassc
COMPONENT_BUILD_TARGETS =	extension
COMPONENT_INSTALL_ARGS +=	VERSION=$(COMPONENT_VERSION) SASS=sassc
COMPONENT_INSTALL_TARGETS =	install

COMPONENT_BUILD_ENV +=		PATH="$(GNUBIN):$(PATH)"
COMPONENT_INSTALL_ENV +=	PATH="$(GNUBIN):$(PATH)"

COMPONENT_POST_INSTALL_ACTION += \
	$(INSTALL) -m 0444 $(COMPONENT_DIR)/files/10_dash-to-dock.gschema.override \
	    $(PROTO_DIR)/usr/share/glib-2.0/schemas/ ;

# Build dependencies
REQUIRED_PACKAGES += developer/sassc
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += text/gnu-gettext

# Run-time
REQUIRED_PACKAGES += gnome/gnome-shell
