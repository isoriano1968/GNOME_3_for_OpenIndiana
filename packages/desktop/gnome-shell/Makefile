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

# GNOME Shell 45.9 as in Solaris 11.4 (solaris-userland components/gnome/
# gnome-shell @9d7a655): X11 only, ConsoleKit login manager (01-consolekit
# plus its two D-Bus interface files in files/), no NetworkManager, portal
# helper, systemd, camera monitor or screencast.  Built against OI's
# gjs 1.90 / mozjs-140 (Solaris: gjs 1.78 / mozjs-115).
# Not taken from Solaris: 02-gdm-logo-size, 04-favorite-apps and
# 06-solaris-background (Solaris branding), 08_VM.sparc (SPARC), and
# 15-revert-AdwToolbarView (only for Solaris' libadwaita 1.3; OI has 1.6).

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-shell
HUMAN_VERSION=		45.9
COMPONENT_SUMMARY=	GNOME Shell - the GNOME desktop user interface
COMPONENT_ARCHIVE_HASH=	\
	sha256:93455dd4cf8a3622d463ea51fd2a74a9c29b85070c22d2bd8d495ac4fcb64c7b
COMPONENT_FMRI=		gnome/gnome-shell
COMPONENT_CLASSIFICATION=	Desktop (GNOME)/Window Managers
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS
CXXFLAGS +=		-D__EXTENSIONS__

COMPONENT_POST_UNPACK_ACTION += $(CP) $(COMPONENT_DIR)/files/*.xml $(SOURCE_DIR)/data/dbus-interfaces ;

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Dnetworkmanager=false
CONFIGURE_OPTIONS +=	-Dportal_helper=false
CONFIGURE_OPTIONS +=	-Dsystemd=false
CONFIGURE_OPTIONS +=	-Dcamera_monitor=false
CONFIGURE_OPTIONS +=	-Dtests=false
CONFIGURE_OPTIONS +=	-Dgtk_doc=false
CONFIGURE_OPTIONS +=	-Dman=false
CONFIGURE_OPTIONS +=	--wrap-mode=nofallback

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

# Versioned python shebangs (as Solaris does), so pkgdepend can resolve them.
COMPONENT_POST_INSTALL_ACTION += \
	$(GSED) -i -e '1s?^\#!/usr/bin/python3$$?\#!/usr/bin/python$(PYTHON_VERSION)?' \
	    $(PROTOUSRBINDIR)/gnome-shell-extension-tool \
	    $(PROTOUSRBINDIR)/gnome-shell-test-tool ;
COMPONENT_BUILD_ENV +=	PATH="$(GNUBIN):$(PATH)"

REQUIRED_PACKAGES += developer/sassc
REQUIRED_PACKAGES += runtime/python-$(subst .,,$(PYTHON_VERSION))
REQUIRED_PACKAGES += library/desktop/gobject/gobject-introspection
REQUIRED_PACKAGES += gnome/config/gsettings-desktop-schemas
REQUIRED_PACKAGES += gnome/gnome-settings-daemon
REQUIRED_PACKAGES += gnome/window-manager/mutter
REQUIRED_PACKAGES += library/audio/pulseaudio
REQUIRED_PACKAGES += library/desktop/evolution-data-server
REQUIRED_PACKAGES += library/desktop/geoclue
REQUIRED_PACKAGES += library/desktop/gjs
REQUIRED_PACKAGES += library/desktop/gnome-autoar
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/desktop/libadwaita
REQUIRED_PACKAGES += library/desktop/libgdm
REQUIRED_PACKAGES += library/desktop/libgweather
REQUIRED_PACKAGES += library/desktop/startup-notification
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/gnome/gcr-4
REQUIRED_PACKAGES += library/libical
REQUIRED_PACKAGES += library/libsoup3
REQUIRED_PACKAGES += system/input-method/ibus
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/accountsservice
REQUIRED_PACKAGES += system/library/polkit
REQUIRED_PACKAGES += system/upower
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/graphene
REQUIRED_PACKAGES += library/desktop/json-glib
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libx11
REQUIRED_PACKAGES += x11/library/libxfixes
REQUIRED_PACKAGES += shell/ksh93
REQUIRED_PACKAGES += library/python/pygobject-$(subst .,,$(PYTHON_VERSION))
REQUIRED_PACKAGES += library/python/simplejson-$(subst .,,$(PYTHON_VERSION))
