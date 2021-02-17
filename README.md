lpython: Linear Python scripts
==============================

**`lpython`** allows executing "Python"-ish scripts in the command line as parts of a pipeline.

_Why?_ Normally, the Python binary allows executing Python script specified in the command-line, but you have to write a proper Python script:

~~~~
python3 -c 'import json
print(json.dumps({0: 1}))
'
~~~~

This may make shell history unreadable, hard to edit, etc.

In addition, accessing information in a pipe, common with most command-line tools, is convoluted.
While you can easily say `some-command-generating-data | grep Foo | awk '{ print $2; }'`, doing a similar thing for data processing in Python is really hard, requiring you to open an editor, save a script file.

**`lpython`** takes this need off for **quick and dirty** command-line data processing.

Installation
------------

> **TODO.**

Overview
--------

Use `lpython` just like you would use `sed` or `awk` in a pipe.
After the optional flags, specify the code to execute:

~~~~
$ seq 1 5 | lpython 'print(int(LINE) * 2);'
2
4
6
8
10
~~~~

LPython works by first *transcoding* the input code to real Python syntax, then *injecting* this input into a context, forming a full source code, and then running this code.

### Optional arguments

Help about individual modes is printed if no code is specified:

~~~~
$ lpython -t lines
Help for the 'lines' mode ...
~~~~

 * **`-n`**: Show the result of the transformed code, but do not execute.
 * **`-b`**: Show the result of the transformed and injected code, but do not execute.
 * **`-t XXX`**: use _`XXX`_ mode.

### Passing command-line arguments

Command-line arguments to `lpython` can be passed to the running script with the **`-X`** optional argument.
The argument vector (list) of the invocation is available inside the script as `ARGS`.

~~~~
$ lpython -X "username" -X "$(date)" 'print(ARGS[1], ARGS[2])'
username "Sun 14 Feb 2021 14:02:33"
~~~~


Usage modes
-----------

### `bare` mode

The bare mode does not perform any pre-parsing or business logic.
This is the default mode when the standard input is a terminal, and not a pipe.
The variables `STDIN`, `STDOUT`, and `STDERR` alias `sys.stdin`, `sys.stdout`, and `sys.stderr`, respectively.

### `lines` mode

Lines mode allows handling each line of the standard input.
This is the default mode if the standard input comes from a pipe.
The values are available through the `LINE` variable.

The functions `OUT` and `ERR` print the arguments to the standard output and
error respectively, without a newline.

#### FizzBuzz

~~~~
$ seq 1 15 | lpython 'if int(LINE) % 15 == 0: print("Fizzbuzz"); ' \
    'elif int(LINE) % 3 == 0: print("Fizz");' \
    'elif int(LINE) % 5 == 0: print("Buzz");' \
    'else: OUT(LINE); endif'
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
Fizzbuzz
~~~~
### `json` mode

The input stream is loaded and parsed as a [JSON](http://json.org), and made available as `DATA`.
This mode is aimed at implementing JSON filters and transformers.
After the user's code executed, the JSON is formatted and printed to the standard output.

#### JSON filter

~~~~
$ echo '[{"Timezone": "Europe/London"}, {"Timezone": "America/New York"}]' | \
    lpython -t json 'for rec in DATA: for k, v in dict(rec).items(): ' \
        'if k == "Timezone": split = v.split("/"); ' \
        'rec["Country"] = split[0]; rec["City"] = split[1]; del rec["Timezone"]; ' \
        'endif; endfor; endfor;'
[{"Country": "Europe", "City": "London"}, {"Country": "America", "City": "New York"}]
~~~~

The JSON mode also offers the `PRETTY()` function, which turns out formatted JSON output:

~~~~
$ echo '[{"Timezone": "Europe/London"}, {"Timezone": "America/New York"}]' | \
    lpython -t json 'for rec in DATA: for k, v in dict(rec).items(): ' \
        'if k == "Timezone": split = v.split("/"); ' \
        'rec["Country"] = split[0]; rec["City"] = split[1]; del rec["Timezone"]; ' \
        'endif; endfor; endfor; ' \
        'PRETTY();'
[
    {
        "City": "London",
        "Country": "Europe"
    },
    {
        "City": "New York",
        "Country": "America"
    }
]
~~~~

### `csv` mode

> **TODO.**


Syntax
------

The code given to `lpython` is generally the same as normal Python code, except for a few key differences:

 * **Lines are terminated by `;` (semicolon)**, instead of a newline. Newlines still work, but the entire idea is to not deal with newlines.
 * Due to not dealing with newlines and whitespace, the indentation-based "scoping" is also side-stepped:
    * Everything that would begin a scope and require indented code is instead closed with an `end___` keyword.
    * For example: `if X: print(X); endif;`, `while True: pass; endwhile;`, `def identity(a): return a; enddef`.

Everything else in-between is expected to behave as it would in Python.
