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

# GNOME Settings (gnome-control-center) 41.7, GTK 3 + libhandy, as in Solaris
# 11.4 (solaris-userland components/gnome/gnome-control-center @9d7a655) with
# all its patches: no Users panel (needs libpwquality), no udisks, gudev, WWAN
# or online accounts, Solaris-style timezone/datetime, and the libv12n
# virtualization info only where libv12n exists (Solaris; not illumos).
# Solaris' -fstack-protector-all is left out.

BUILD_BITS=		64
BUILD_STYLE=		meson

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gnome-control-center
HUMAN_VERSION=		41.7
COMPONENT_SUMMARY=	GNOME Settings (gnome-control-center)
COMPONENT_ARCHIVE_HASH=	\
	sha256:95f905248247c722d02e950ce55fb35ef3a9d25cad8a67c0012a71e5acf0cf08
COMPONENT_FMRI=		gnome/preferences/control-center
COMPONENT_CLASSIFICATION=	Applications/Configuration and Preferences
COMPONENT_LICENSE=	GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/gnome.mk
include $(WS_MAKE_RULES)/common.mk

CFLAGS +=		-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS

CONFIGURE_OPTIONS +=	--libexecdir=$(USRLIBEXECDIR)
CONFIGURE_OPTIONS +=	-Ddocumentation=false
CONFIGURE_OPTIONS +=	-Dibus=true
CONFIGURE_OPTIONS +=	-Dcheese=false
CONFIGURE_OPTIONS +=	-Dwayland=false
CONFIGURE_OPTIONS +=	-Dsnap=false
CONFIGURE_OPTIONS +=	-Dmalcontent=false
CONFIGURE_OPTIONS +=	-Dtests=false

CONFIGURE_ENV +=	PATH="$(GNUBIN):$(PATH)"

# gnome-shell 45 looks for Settings as org.gnome.Settings.desktop (the name
# gnome-control-center took in 42); 41 installs gnome-control-center.desktop.
# Rename it, so the shell's Settings button works and it stops warning
# "Missing required core component Settings".
COMPONENT_POST_INSTALL_ACTION += \
	$(MV) $(PROTO_DIR)/usr/share/applications/gnome-control-center.desktop \
	    $(PROTO_DIR)/usr/share/applications/org.gnome.Settings.desktop ;

REQUIRED_PACKAGES += gnome/config/gsettings-desktop-schemas
REQUIRED_PACKAGES += gnome/gnome-settings-daemon
REQUIRED_PACKAGES += library/audio/pulseaudio
REQUIRED_PACKAGES += library/desktop/colord-gtk
REQUIRED_PACKAGES += library/desktop/gnome-desktop
REQUIRED_PACKAGES += library/desktop/gsound
REQUIRED_PACKAGES += library/desktop/gtk3
REQUIRED_PACKAGES += library/libhandy
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += library/libgtop
REQUIRED_PACKAGES += library/libsecret
REQUIRED_PACKAGES += library/libxml2
REQUIRED_PACKAGES += service/image/colord
REQUIRED_PACKAGES += system/input-method/ibus
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/accountsservice
REQUIRED_PACKAGES += system/library/polkit
REQUIRED_PACKAGES += system/upower
REQUIRED_PACKAGES += gnome/accessibility/at-spi2-core
REQUIRED_PACKAGES += library/desktop/cairo
REQUIRED_PACKAGES += library/desktop/gdk-pixbuf
REQUIRED_PACKAGES += library/desktop/pango
REQUIRED_PACKAGES += system/library/fontconfig
REQUIRED_PACKAGES += system/library/math
REQUIRED_PACKAGES += x11/library/libepoxy
REQUIRED_PACKAGES += x11/library/libx11
