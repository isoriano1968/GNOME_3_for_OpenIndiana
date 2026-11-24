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
#

USE_PARALLEL_BUILD= yes
BOOTSTRAP_COMPONENT= no
include ../../../make-rules/shared-macros.mk

# SPARC (OpenIndiana project, on oi-userland's developer/gcc-14 at
# d87ae8ac6; the x86 build is unchanged by these blocks).  OI SPARC has gcc 13
# only, whose exception tables illumos ld could not index (notes/
# gnome3-sparc.md, section 6).  gcc 14 is built against an illumos linker
# with the unaligned-DISP32 fix (illumos-gate 44a46dab27/57dbbcd0b7), so that
# configure itself finds HAVE_AS_SPARC_UA_PCREL; nothing is forced.  The
# first SPARC gcc 14 is bootstrapped with gcc 13 (COMPONENT_BOOTSTRAP=yes,
# the recipe's own mechanism).  SPARC settings as in OI SPARC's gcc 13:
# triplet sparcv9-sun-solaris2.11, --with-cpu=ultrasparc (US-IIIi and T4).
ifeq ($(MACH),sparc)
COMPONENT_BOOTSTRAP ?= yes
endif

COMPONENT_VERSION= 14.3.0
COMPONENT_REVISION= 4
COMPONENT_SRC= gcc-releases-gcc-$(COMPONENT_VERSION)
COMPONENT_ARCHIVE= $(COMPONENT_NAME)-$(COMPONENT_VERSION).tar.gz
COMPONENT_ARCHIVE_URL= https://github.com/gcc-mirror/gcc/archive/releases/$(COMPONENT_ARCHIVE)
COMPONENT_ARCHIVE_HASH= sha256:f96f6dd42443b9920478c9e4de49d3d5609fff36c67d5b490ded2e0101bfc053

MPFR_VERSION= 4.2.1
MPFR_ARCHIVE_HASH= sha256:b9df93635b20e4089c29623b19420c4ac848a1b29df1cfd59f26cab0d2666aa0

MPC_VERSION= 1.3.1
MPC_ARCHIVE_HASH= sha256:ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8

GMP_VERSION= 6.3.0
GMP_ARCHIVE_HASH= sha256:ac28211a7cfb609bae2e2c8d6058d66c8fe96434f740cf6fe2e47b000d1c20cb

include $(WS_MAKE_RULES)/gcc-component.mk

ifeq ($(COMPONENT_BOOTSTRAP),yes)
CC=/usr/gcc/13/bin/gcc
CXX=/usr/gcc/13/bin/g++
# Use gcc's default flags
CFLAGS=
CPPFLAGS=
CXXFLAGS=
else
CC=/usr/gcc/$(GCC_MAJOR)/bin/gcc
CXX=/usr/gcc/$(GCC_MAJOR)/bin/g++
endif

CPPFLAGS += " -D_TS_ERRNO"
LDFLAGS= "-R$OPT/lib"

GCC_MAJOR= $(GCC_COMPONENT_VERSION_MAJOR)
PKG_VARS += GCC_MAJOR
PKG_MACROS +=   GCC_MAJOR_VERSION=$(GCC_MAJOR)
PKG_MACROS +=   GCC_VERSION=$(GCC_VERSION)
PKG_MACROS +=   GCC_BASEDIR=usr/gcc/$(GCC_MAJOR)

# Workaround platform definition inconsistency
PARCH.i386= x86_64-pc
PARCH.sparc= sparcv9-sun
PARCH= $(PARCH.$(MACH))

GNU_TRIPLET= $(PARCH)-solaris$(SOLARIS_VERSION)
PKG_MACROS += GNU_TRIPLET="$(GNU_TRIPLET)"

COMPONENT_PRE_CONFIGURE_ACTION += \
	cd $(SOURCE_DIR) && autogen Makefile.def

CONFIGURE_BINDIR.64= $(CONFIGURE_PREFIX)/bin
CONFIGURE_LIBDIR.64= $(CONFIGURE_PREFIX)/lib

CONFIGURE_OPTIONS += --with-ld=$(LD) --without-gnu-ld
CONFIGURE_OPTIONS += --with-as=/usr/bin/gas --with-gnu-as
CONFIGURE_OPTIONS.i386 += --with-build-time-tools=/usr/gnu/${TRIPLETS[amd64]}/bin
CONFIGURE_OPTIONS.sparc += --with-build-time-tools=/usr/gnu/$(GNU_TRIPLET)/bin
CONFIGURE_OPTIONS.sparc += --with-cpu=ultrasparc
CONFIGURE_OPTIONS += $(CONFIGURE_OPTIONS.$(MACH))
CONFIGURE_OPTIONS += --with-build-config=no
CONFIGURE_OPTIONS += --enable-languages=c,c++,fortran,go,objc
CONFIGURE_OPTIONS += --enable-shared
CONFIGURE_OPTIONS += --with-system-zlib
CONFIGURE_OPTIONS += --enable-plugins
CONFIGURE_OPTIONS += --enable-__cxa_atexit
CONFIGURE_OPTIONS += --enable-initfini-array
CONFIGURE_OPTIONS += --enable-clocale=dragonfly
CONFIGURE_OPTIONS += --with-diagnostics-urls=auto-if-env
CONFIGURE_OPTIONS += enable_frame_pointer=yes

COMPONENT_TEST_ENV += LC_ALL=C.UTF-8

COMPONENT_TEST_TRANSFORMS= -n \
	"-e '/Running/p' " \
	"-e '/Summary/p' " \
	"-e '/\# of/p' "

PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/g++
PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/gcc
PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/gcc-ar
PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/gcc-nm
PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/gcc-ranlib
PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/gccgo
PKG_HARDLINKS += usr/gcc/$(GCC_MAJOR)/bin/gfortran

# Auto-generated dependencies
REQUIRED_PACKAGES += compress/zstd
REQUIRED_PACKAGES += developer/gnu-binutils
REQUIRED_PACKAGES += developer/linker
REQUIRED_PACKAGES += library/zlib
REQUIRED_PACKAGES += shell/ksh93
REQUIRED_PACKAGES += system/header
REQUIRED_PACKAGES += system/library
REQUIRED_PACKAGES += system/library/c-runtime
REQUIRED_PACKAGES += system/library/math
