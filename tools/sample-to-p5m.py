#!/usr/bin/python3 -I
"""sample-to-p5m.py -- turn an oi-userland "gmake sample-manifest" result into
a component's .p5m, the way the GNOME port's components are written.

  tools/sample-to-p5m.py SAMPLE.p5m OUT.p5m [--note TEXT] [--extra FILE]

- Copyright line set to the author, an optional note added below it.
- pkg.human-version dropped when HUMAN_VERSION is not used (harmless either
  way; kept when present in the sample).
- Every D-Bus system policy file (etc/dbus-1/system.d, usr/share/dbus-1/
  system.d) gets refresh_fmri=svc:/system/dbus:default: OpenIndiana has no
  dbus actuator, and a dbus-daemon that never reloads its policies drops the
  new bus names (this broke the MATE login on 2026-11-08).
- --extra FILE: actions (dir, user, depend ...) inserted after the license.
"""
import argparse
import re

ap = argparse.ArgumentParser()
ap.add_argument("sample")
ap.add_argument("out")
ap.add_argument("--note", default="")
ap.add_argument("--extra")
a = ap.parse_args()

text = open(a.sample).read()
text = text.replace("# Copyright 2026 <contributor>\n#\n",
                    "# Copyright 2026 isoriano1968\n#\n" +
                    "".join("# " + l + "\n" if l else "#\n"
                            for l in a.note.splitlines()) +
                    ("#\n" if a.note else ""))

# join continuation lines, add refresh_fmri, re-wrap
joined = re.sub(r"\\\n\s+", " ", text)
out = []
for line in joined.splitlines():
    if line.startswith("file ") and re.search(r"path=(etc|usr/share)/dbus-1/system\.d/", line):
        if "refresh_fmri" not in line:
            line += " refresh_fmri=svc:/system/dbus:default"
    if len(line) > 79 and re.match(r"(file|link|dir|hardlink) .*path=", line):
        head, _, rest = line.partition(" path=")
        parts = ("path=" + rest).split(" ")
        cur = head + " " + parts[0]
        lines = []
        for p in parts[1:]:
            if len(cur) + 1 + len(p) > 79:
                lines.append(cur + " \\")
                cur = "    " + p
            else:
                cur += " " + p
        lines.append(cur)
        line = "\n".join(lines)
    out.append(line)
text = "\n".join(out) + "\n"

if a.extra:
    extra = open(a.extra).read().rstrip("\n") + "\n"
    anchor = "license $(COMPONENT_LICENSE_FILE) license='$(COMPONENT_LICENSE)'\n"
    if anchor not in text:
        raise SystemExit("sample-to-p5m: license action not found")
    text = text.replace(anchor, anchor + "\n" + extra, 1)

open(a.out, "w").write(text)
