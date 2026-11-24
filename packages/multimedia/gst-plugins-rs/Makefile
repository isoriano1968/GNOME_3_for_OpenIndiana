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

# gst-plugins-rs 0.15.4 (the GStreamer 1.28 series of the Rust plugins),
# only the gtk4 plugin: gtk4paintablesink, a GdkPaintable sink that GTK 4
# applications such as Showtime (desktop/showtime) draw.  GL through GTK's
# context (x11egl, x11glx; gst-plugins-base's GL winsys decide), GTK 4.16
# API level.  The other plugins are not built: -Dauto_features=disabled.
# Crates are vendored by make-rules/cargo-vendor.mk (the workspace's whole
# Cargo.lock), the build is offline.  meson needs cargo-c.

BUILD_BITS=		64
BUILD_STYLE=		meson
CARGO_VENDOR=		yes

include ../../../make-rules/shared-macros.mk

COMPONENT_NAME=		gst-plugins-rs
COMPONENT_VERSION=	0.15.4
COMPONENT_REVISION=	1
COMPONENT_SUMMARY=	GStreamer Rust plugins: gtk4paintablesink
COMPONENT_PROJECT_URL=	https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs
COMPONENT_SRC=		$(COMPONENT_NAME)-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	\
	sha256:2c19ed8316695782b782135ba35601a78886e16f5197965aab66d26f477534ed
COMPONENT_ARCHIVE_URL=	$(COMPONENT_PROJECT_URL)/-/archive/$(COMPONENT_VERSION)/$(COMPONENT_ARCHIVE)
COMPONENT_FMRI=		library/audio/gstreamer/plugin/gtk4
COMPONENT_CLASSIFICATION=	System/Multimedia Libraries
COMPONENT_LICENSE=	MPL-2.0
COMPONENT_LICENSE_FILE=	LICENSE-MPL-2.0

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/common.mk

CONFIGURE_OPTIONS +=	-Dauto_features=disabled
CONFIGURE_OPTIONS +=	-Dgtk4=enabled
CONFIGURE_OPTIONS +=	-Ddoc=disabled
CONFIGURE_OPTIONS +=	-Dexamples=disabled
CONFIGURE_OPTIONS +=	-Dtests=disabled

# cargo runs offline on the vendored crates (cargo-vendor.mk's config.toml)
COMPONENT_BUILD_ENV +=	CARGO_NET_OFFLINE=true
# no build paths in the plugin: RUST_PATH_MAP (make-rules) for the code;
# cargo links with an absolute -o, which illumos ld names in a FILE symbol
# (.symtab, .SUNW_ldynsym/.dynstr), so the plugin is linked without the
# local symbol tables (-z noldynsym, stripped symbols).
PLUGIN_RUSTFLAGS =	$(RUST_PATH_MAP) -C strip=symbols \
			-C link-arg=-Wl,-z,noldynsym
COMPONENT_BUILD_ENV +=	RUSTFLAGS="$(PLUGIN_RUSTFLAGS)"
COMPONENT_INSTALL_ENV +=	RUSTFLAGS="$(PLUGIN_RUSTFLAGS)"

# build dependencies
REQUIRED_PACKAGES +=	developer/cargo-c
REQUIRED_PACKAGES +=	developer/lang/rustc
# Auto-generated dependencies
REQUIRED_PACKAGES += $(GCC_RUNTIME_PKG)
REQUIRED_PACKAGES += library/audio/gstreamer
REQUIRED_PACKAGES += library/audio/gstreamer/plugin/base
REQUIRED_PACKAGES += library/desktop/graphene
REQUIRED_PACKAGES += library/desktop/gtk4
REQUIRED_PACKAGES += library/glib2
REQUIRED_PACKAGES += system/library
