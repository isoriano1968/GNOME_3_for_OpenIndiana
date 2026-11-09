#!/usr/bin/python3 -I
"""new-meson-component.py -- write the Makefile of a meson-built GNOME-style
oi-userland component in packages/<category>/<name>, the way the GNOME
port's components are written.  The .p5m and license come later from
tools/oi-pipeline.sh (manifest step).

  tools/new-meson-component.py SPEC.json

SPEC.json: {"dir": "desktop/gnome-text-editor", "name": "gnome-text-editor",
  "version": "47.4", "url": "https://...tar.xz", "sha256": "...",
  "fmri": "editor/gnome-text-editor", "classification": "...",
  "license": "GPL-3.0-or-later", "summary": "...",
  "project_url": "https://...", "comment": "text for the header",
  "options": ["-Dfoo=false", ...], "cflags": "...", "ldflags": "...",
  "packages": ["library/glib2", ...]}
Refuses to overwrite an existing Makefile.
"""
import json
import os
import sys
import textwrap

spec = json.load(open(sys.argv[1]))
top = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
cdir = os.path.join(top, "packages", spec["dir"])
mk = os.path.join(cdir, "Makefile")
if os.path.exists(mk):
    raise SystemExit(f"{mk} exists")
os.makedirs(cdir, exist_ok=True)

head = """#
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

"""
comment = "\n".join("# " + l if l else "#" for l in
                    textwrap.fill(spec["comment"], 74).splitlines())
lines = [head + comment, "",
         "BUILD_BITS=\t\t64", "BUILD_STYLE=\t\tmeson", "",
         "include ../../../make-rules/shared-macros.mk", "",
         f"COMPONENT_NAME=\t\t{spec['name']}",
         f"HUMAN_VERSION=\t\t{spec['version']}",
         f"COMPONENT_SUMMARY=\t{spec['summary']}",
         f"COMPONENT_PROJECT_URL=\t{spec['project_url']}",
         "COMPONENT_ARCHIVE_HASH=\t\\",
         f"\tsha256:{spec['sha256']}",
         f"COMPONENT_FMRI=\t\t{spec['fmri']}",
         f"COMPONENT_CLASSIFICATION=\t{spec['classification']}",
         f"COMPONENT_LICENSE=\t{spec['license']}",
         "COMPONENT_LICENSE_FILE=\t$(COMPONENT_NAME).license", "",
         "TEST_TARGET=\t\t$(NO_TESTS)", "",
         f"COMPONENT_ARCHIVE_URL=\t{spec['url']}",
         "include $(WS_MAKE_RULES)/gnome.mk",
         "include $(WS_MAKE_RULES)/common.mk", "",
         "CFLAGS +=\t\t-D__EXTENSIONS__ -D_POSIX_PTHREAD_SEMANTICS"]
if spec.get("cflags"):
    lines.append(f"CFLAGS +=\t\t{spec['cflags']}")
if spec.get("ldflags"):
    lines.append(f"LDFLAGS +=\t\t{spec['ldflags']}")
lines += ["", "CONFIGURE_OPTIONS +=\t--libexecdir=$(USRLIBEXECDIR)"]
lines += [f"CONFIGURE_OPTIONS +=\t{o}" for o in spec.get("options", [])]
lines += ["", 'CONFIGURE_ENV +=\tPATH="$(GNUBIN):$(PATH)"', ""]
lines += [f"REQUIRED_PACKAGES += {p}" for p in spec.get("packages", [])]
open(mk, "w").write("\n".join(lines) + "\n")
print(mk)
