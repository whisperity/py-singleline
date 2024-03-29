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

EXPECTED=$(cat <<-EOM
Foo
EOM
)

RESULT_NOTPIPE=$(python3 -m pysln 'print(LINE);' 2>&1)

EXPECTED_ERROR="NameError: name 'LINE' is not defined"
TEST_NOTPIPE=$(echo "$RESULT_NOTPIPE" | grep "$EXPECTED_ERROR")
if [[ $? -ne 0 ]]
then
    echo "[ERROR] Received output:" >&2
    echo "----------------------------------------" >&2
    echo -e "$RESULT" >&2
    echo "----------------------------------------" >&2
    echo "Does NOT contain:" >&2
    echo "----------------------------------------" >&2
    echo -e "$EXPECTED_ERROR" >&2
    echo "----------------------------------------" >&2

    echo "FAIL" >> $SOCKET
fi

RESULT_PIPE=$(echo "Foo" | python3 -m pysln 'print(LINE);')

if [[ "$EXPECTED" != "$RESULT_PIPE" ]]
then
    echo "[ERROR] Received output:" >&2
    echo "----------------------------------------" >&2
    echo -e "$RESULT_PIPE" >&2
    echo "----------------------------------------" >&2
    echo "Does NOT match expected output:" >&2
    echo "----------------------------------------" >&2
    echo -e "$EXPECTED" >&2
    echo "----------------------------------------" >&2

    echo "FAIL" >> $SOCKET
fi

echo "OK" >> $SOCKET
