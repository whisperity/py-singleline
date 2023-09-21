# Copyright (C) 2020 Whisperity
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import subprocess

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

with open("README.md", encoding="utf-8", errors="ignore") as md:
    long_description = md.read()

try:
    commit = subprocess.check_output(["git", "rev-parse", "--short", "HEAD"])
    commit = commit.decode().strip()
except subprocess.CalledProcessError:
    commit = "0000000"
except OSError:
    commit = "0000000"

try:
    version = subprocess.check_output(["git", "describe", "--tags",
                                       "--dirty=\"-dirty\""])
    version = version.decode().strip()
    if version[0] == "v":
        version = version[1:]
    version = version.replace("-dirty", "dev")
    version_parts = version.split("-")
    if len(version_parts) == 1:
        version = version_parts[0]
    else:
        # Skip the commit count and inject the hash only.
        version = version_parts[0] + "+" + version_parts[2]
except subprocess.CalledProcessError:
    # No version tag found.
    version = "0.0.0+" + commit
except OSError:
    version = "0.0.0"


setup(
    name="py-singleline",
    description="Arbitrarily complex single-line Python scripts",
    version=version,
    author="Whisperity",
    author_email="whisperity-packages@protonmail.com",
    long_description=long_description,
    long_description_content_type='text/markdown',
    url="http://github.com/whisperity/py-singleline",
    license="GPLv3+",
    keywords="python shell pipeline script scripting",
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Intended Audience :: End Users/Desktop",
        "Intended Audience :: Information Technology",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: GNU General Public License v3 or "
        "later (GPLv3+)",
        "Operating System :: MacOS",
        "Operating System :: POSIX :: Linux",
        "Operating System :: Unix",
        "Programming Language :: Python :: 3 :: Only",
        "Topic :: Software Development",
        "Topic :: System :: Shells"
        ],
    python_requires=">=3.6",

    packages=["py_singleline",
              "py_singleline.modes",
              "pysln"
              ],
    package_dir={
        "py_singleline": "src/py_singleline",
        "pysln": "src/pysln"
        },

    entry_points={
        "console_scripts": [
            "pysln=pysln.pysln:main"
            ]
        }
)
