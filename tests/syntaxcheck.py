"""Compile every Lua file the addon loads, without running any of it.

    python tests/syntaxcheck.py                 # every file listed in the .toc
    python tests/syntaxcheck.py VendorSearch.lua  # or just the ones named

With no arguments the list comes from the .toc, which is the authority on what
the game actually loads -- a hand-maintained list here would go stale the first
time a file was added, and a broken file could ship with CI green.

The .toc is located by globbing rather than by name, so this file can be copied
between addon projects unchanged.
"""
import glob
import os
import sys

import lupa

_here = os.path.dirname(os.path.abspath(__file__))
ADDON_DIR = os.path.dirname(_here)


def find_toc():
    tocs = sorted(glob.glob(os.path.join(ADDON_DIR, "*.toc")))
    if not tocs:
        sys.exit("no .toc file found in %s" % ADDON_DIR)
    # Multi-flavour projects carry Foo_Mists.toc etc. alongside Foo.toc; the
    # shortest name is the base one and they all list the same Lua files.
    return min(tocs, key=len)


def files_from_toc(toc):
    out = []
    with open(toc, encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if line and not line.startswith("#") and line.lower().endswith(".lua"):
                out.append(os.path.join(ADDON_DIR, line))
    if not out:
        sys.exit("no Lua files listed in %s" % toc)
    return out


lua = lupa.LuaRuntime(unpack_returned_tuples=True)
load = lua.eval("function(src, name) local f, e = load(src, name); return (f ~= nil), e end")

paths = sys.argv[1:] or files_from_toc(find_toc())
ok = True
for path in paths:
    src = open(path, encoding="utf-8").read()
    fn, err = load(src, "@" + path)
    if not fn:
        ok = False
        print("SYNTAX ERROR in %s:\n  %s" % (path, err))
    else:
        print("ok: %s" % os.path.basename(path))
sys.exit(0 if ok else 1)
