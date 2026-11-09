# hal: GPT partitions become volumes (upstream submission, prepared, not submitted)

Everything here is local. Filing the issue and uploading the change are the
user's steps, from their own accounts. Nothing has been posted.

| File | What |
|---|---|
| `0001-NNNNN-hal-GPT-partitions-of-removable-disks-never-be.patch` | the change, `git format-patch` against illumos-gate master b1c424a261 (2026-11-08); author isoriano1968, no trailers |
| `issue.md` | text for the illumos-gate issue (symptom, cause, fix) |
| `testing.md` | what was built and tested, and what is still to do |

Commit message format (illumos): one line, `<issue number> <synopsis>`,
here `NNNNN hal: GPT partitions of removable disks never become volumes`,
no body (the explanation goes in the issue). Replace NNNNN with the issue
number once it is filed. Reviewers' lines are added later as
`Reviewed by: Name <email>`; the integrator adds `Approved by:`.

## Steps (see ../audiohd-apple/upstream/README.md for the details)

1. Finish testing.md (re-plug, a GPT FAT32 stick, an MBR stick).
2. File the issue at https://www.illumos.org/projects/illumos-gate/issues/new
   with issue.md; note the number.
3. In a clone of https://github.com/illumos/illumos-gate: `git am` the
   patch, `git commit --amend` to put the number in place of NNNNN.
4. Nightly build with the change, clean mail_msg, `git pbchk`.
5. Gerrit (https://code.illumos.org): commit-msg hook, push for review,
   "Testing Done" in the issue.
6. RTI to advocates@lists.illumos.org once reviewed.

## Local use until it is integrated

The same patch file is in packages/sysutils/hal-probe-storage-gpt/patches/,
which builds the package system/hal/probe-storage-gpt (publisher oi-gnome):
the patched prober as /usr/lib/hal/oi/hald-probe-storage, used once
`svccfg -s system/hal setenv HALD_RUNNER_PATH /usr/lib/hal/oi` is set.

- It replaces no file of service/hal, so `pkg update` of service/hal does
  not conflict with it and leaves it in place. Once a fixed illumos ships,
  remove it: `svccfg -s system/hal unsetenv HALD_RUNNER_PATH`,
  `svcadm refresh system/hal; svcadm restart system/hal`, `pkg uninstall
  system/hal/probe-storage-gpt`.
- The same three commands go back to the stock prober at any time; no new
  BE is needed.
- One drawback: if a later illumos changes hald-probe-storage, the copy in
  /usr/lib/hal/oi stays the old version until this package is rebuilt.

NTFS also needs system/file-system/fstyp-ntfs (a libfstyp module, because
ntfsprogs ships only a shell script as /usr/lib/fs/ntfs-3g/fstyp): that is
an OpenIndiana matter, not part of this illumos change.
