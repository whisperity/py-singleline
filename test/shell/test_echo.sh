#!/bin/bash
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

SOCKET="$1"

if [[ $(hostname) != $(hostname | python3 -m pysln -t lines 'print(LINE);') ]]
then
    echo $(hostname)" echo failed." >&2
    echo "FAIL" >> $SOCKET
fi

if [[ $(id) != $(id | python3 -m pysln -t lines 'print(LINE);') ]]
then
    echo $(id)" echo failed." >&2
    echo "FAIL" >> $SOCKET
fi


if [[ $(ls -l) != $(ls -l | python3 -m pysln -t lines 'print(LINE);') ]]
then
    echo $(ls -l)" echo failed." >&2
    echo "FAIL" >> $SOCKET
fi

echo "OK" >> $SOCKET
