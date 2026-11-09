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

# hald-probe-storage from illumos-gate with patches/0001-NNNNN-hal-*.patch
# (the same file as ports/hal-gpt-volumes/upstream, the illumos-gate
# submission), so
# that HAL creates volumes for the partitions of GPT disks (USB drives
# formatted by Windows or macOS): illumos' prober sets
# storage.solaris.vtoc_slices only for VTOC labels, and hald then probes no
# slice of a GPT disk.  The proper place for the fix is illumos-gate (one
# line, see the patch); until it is there, this package delivers the patched
# prober as /usr/lib/hal/oi/hald-probe-storage, next to illumos' own
# /usr/lib/hal/hald-probe-storage, and hald is pointed at it with
#   svccfg -s system/hal setenv HALD_RUNNER_PATH /usr/lib/hal/oi
#   svcadm refresh system/hal; svcadm restart system/hal
# (hald_runner.c puts HALD_RUNNER_PATH in front of /usr/lib/hal).  Only
# probing/storage, utils and hald/logger.c of the tarball are built; 64-bit
# (illumos' prober is 32-bit, both work).

BUILD_BITS=		64
BUILD_STYLE=		justmake

include ../../../make-rules/shared-macros.mk

ILLUMOS_COMMIT=		b1c424a261b16b9c81280c0eb6de8b2f9f4ffacb

COMPONENT_NAME=		hal-probe-storage-gpt
COMPONENT_VERSION=	0.5.8.1
COMPONENT_SUMMARY=	HAL storage prober with GPT partitions (illumos hald-probe-storage, patched)
COMPONENT_PROJECT_URL=	https://illumos.org/
COMPONENT_SRC=		illumos-gate-$(ILLUMOS_COMMIT)
COMPONENT_ARCHIVE=	$(COMPONENT_SRC).tar.gz
COMPONENT_ARCHIVE_HASH=	\
	sha256:6ab3fc7adbad261af3c3f6a967c2588758ce1c13b2f786cf524714bd0c345d64
COMPONENT_ARCHIVE_URL=	https://github.com/illumos/illumos-gate/archive/$(ILLUMOS_COMMIT).tar.gz
COMPONENT_FMRI=		system/hal/probe-storage-gpt
COMPONENT_CLASSIFICATION=	System/Hardware
COMPONENT_LICENSE=	AFL-2.1 OR GPL-2.0-or-later
COMPONENT_LICENSE_FILE=	$(COMPONENT_NAME).license

TEST_TARGET=		$(NO_TESTS)

include $(WS_MAKE_RULES)/common.mk

HAL_SRC=		$(SOURCE_DIR)/usr/src/cmd/hal
HAL_CPPFLAGS=		-DPACKAGE_DATA_DIR=\"/usr/share\" \
			-DPACKAGE_BIN_DIR=\"/usr/bin\" \
			-DPACKAGE_LIBEXEC_DIR=\"/usr/lib/hal\" \
			-DPACKAGE_SCRIPT_DIR=\"/usr/lib/hal\" \
			-DPACKAGE_LOCALSTATEDIR=\"/var\" \
			-DPACKAGE_SYSCONF_DIR=\"/etc\" \
			-DPACKAGE_VERSION=\"0.5.8\" \
			-DHAVE_POLKIT -DDBUS_API_SUBJECT_TO_CHANGE \
			-I/usr/include/dbus-1.0 -I/usr/lib/$(MACH64)/dbus-1.0/include \
			-I/usr/include/hal -I$(HAL_SRC)/utils -I$(HAL_SRC)/hald

COMPONENT_BUILD_ACTION = \
	$(MKDIR) $(@D) ; \
	$(CC) $(CC_BITS) -std=gnu99 $(CFLAGS) $(HAL_CPPFLAGS) \
	    -o $(@D)/hald-probe-storage \
	    $(HAL_SRC)/probing/storage/probe-storage.c \
	    $(HAL_SRC)/utils/cdutils.c $(HAL_SRC)/utils/fsutils.c \
	    $(HAL_SRC)/hald/logger.c \
	    $(LDFLAGS) -ldbus-1 -lhal -ladm -lefi

COMPONENT_INSTALL_ACTION = \
	$(INSTALL) -D -m 0555 $(BUILD_DIR_64)/hald-probe-storage \
	    $(PROTO_DIR)/usr/lib/hal/oi/hald-probe-storage

REQUIRED_PACKAGES += system/library/dbus
REQUIRED_PACKAGES += service/hal
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/libdbus
