#!/usr/bin/env python

import os
from setuptools import setup, Extension
import subprocess

try:
    from Cython.Build import cythonize
except ImportError:
    USE_CYTHON = False
else:
    USE_CYTHON = True

VERSION = "0.1.1"
DEBUG = False

def pkgconfig(*packages, **kw):
    flag_map = {"-I": "include_dirs", "-L": "library_dirs", "-l": "libraries"}
    for token in subprocess.check_output(["pkg-config", "--libs", "--cflags"] + list(packages)).split():
        token = token.decode()
        if token[:2] in flag_map:
            kw.setdefault(flag_map.get(token[:2]), []).append(token[2:])
        else:
            kw.setdefault("extra_compile_args", []).append(token)
    return kw

ext = ".pyx" if USE_CYTHON else ".c"
flags = pkgconfig("smartcols")
if DEBUG:
    flags["define_macros"] = [("CYTHON_TRACE", 1)]
extensions = [Extension("smartcols", ["smartcols"+ext], **flags)]
if USE_CYTHON:
    extensions = cythonize(extensions, gdb_debug=DEBUG)

setup(
    name="smartcols",
    version=VERSION,
    description="Python bindings for the util-linux libsmartcols library",
    platforms=["Linux"],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Cython",
        "Programming Language :: C",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
    ],
    author="Igor Gnatenko",
    author_email="i.gnatenko.brain@gmail.com",
    maintainer="Igor Gnatenko",
    maintainer_email="i.gnatenko.brain@gmail.com",
    url="https://github.com/ignatenkobrain/python-smartcols",
    download_url="https://github.com/ignatenkobrain/python-smartcols/archive/v{}.tar.gz".format(VERSION),
    ext_modules=extensions,
    test_suite="tests",
)
