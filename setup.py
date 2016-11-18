#!/usr/bin/env python

import os
import subprocess
import sys

from Cython.Build import cythonize
from setuptools import setup, Extension

VERSION = "0.2.0"
DEBUG = False

def pkgconfig(package, min_version=None, **kw):
    flag_map = {"-I": "include_dirs", "-L": "library_dirs", "-l": "libraries"}
    # Does .pc exist?
    subprocess.check_call(["pkg-config", "--exists", package])
    if min_version:
        # Does it fulfil version requirement?
        subprocess.check_call(["pkg-config", "--atleast-version", min_version, package])
    # Get parse everything else
    tokens = subprocess.check_output(["pkg-config", "--libs", "--cflags", package],
                                     universal_newlines=True)
    for token in tokens.split():
        if token[:2] in flag_map:
            kw.setdefault(flag_map.get(token[:2]), []).append(token[2:])
        else:
            kw.setdefault("extra_compile_args", []).append(token)
    return kw

flags = pkgconfig("smartcols", "2.29")
if DEBUG:
    flags["define_macros"] = [("CYTHON_TRACE", 1)]
extensions = [Extension("smartcols", ["smartcols.pyx"], **flags)]

needs_pytest = {"pytest", "test", "ptr"}.intersection(sys.argv)
pytest_runner = ["pytest-runner"] if needs_pytest else []

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
    ext_modules=cythonize(extensions, gdb_debug=DEBUG),
    setup_requires=["Cython>=0.24.0", "pytest-runner"],
    tests_require=["pytest>=2.8"],
)
