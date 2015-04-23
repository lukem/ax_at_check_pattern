README
======

This project contains a collection of scripts and autotest macros
offering the following functionality:

  * `check_pattern.awk` to post-process the output of `diff PATTERN OUTPUT` to remove blocks that don't differ if a given line in PATTERN matches the equivalent OUTPUT line as an `awk` regular expression.
  * `pyrediff.py` to post-process the output of `diff PYRE OUTPUT` to remove blocks that don't differ if a given line in PYRE matches the equivalent OUTPUT line as a `python` regular expression. Named groups `(?P<name>...)` can be used in subsequent patterns with `\g<name>`.
  * autotest checks with pattern (`awk` regular expression) and pyre (`python` regular expression) support.

(autotest is part of [autoconf](https://www.gnu.org/software/autoconf/))

Available autotest Macros
-------------------------

### awk regular expression patterns

Macros that support awk regular expressions in the pattern:

  * `AX_AT_CHECK_PATTERN()`: similar to `AT_CHECK()`, except that stdout and stderr are awk regular expressions (REs).
  * `AX_AT_DIFF_PATTERN()`: checks that a pattern file applies to a test file.
  * `AX_AT_DATA_CHECK_PATTERN_AWK()`: create a file with the contents of the awk script used by `AX_AT_CHECK_PATTERN()` and `AX_AT_DIFF_PATTERN()`.

### python regular expression (pyre) patterns

Macros that support [python regular expressions](https://docs.python.org/2/library/re.html):

  * `AX_AT_CHECK_PYREDIFF()`: similar to `AT_CHECK()`, except that stdout and stderr are python regular expressions.
  * `AX_AT_DIFF_PYRE()`: checks that a pattern file applies to a test file.
  * `AX_AT_DATA_PYREDIFF_PY()`: create a file with the contents of the python script used by `AX_AT_CHECK_PYREDIFF()` and `AX_AT_DIFF_PYRE()`.

Strings captured in a named group using `(?P<name>...)` can be used in subsequent pattern lines with `\g<name>`; occurrences of `\g<name>` in the pattern line will be replaced with a previously captured value before the pattern is applied.

Examples
--------

### Example 1: Simple example

Given pattern file `1.pattern`:

```
First line
Second line with a date .*\.
```

and output file `1.output`:

```
First line
Second line with a date 2014-11-22T16:41:00.
```

the output of `diff 1.pattern 1.output` is:

```
% diff 1.pattern 1.output
2c2
< Second line with a date .*\.
---
> Second line with a date 2014-11-22T16:41:00.
```

and filtered with `awk -f check_pattern.awk`:

```
% diff 1.pattern 1.output | awk -f check_pattern.awk
```

or filtered with `python pyrediff.py`:

```
% diff 1.pattern 1.output | python pyrediff.py
```

There is no output because the regex on the second line of 1.pattern
matches that of the second line of 1.output.

### Example 2: Extra lines in output

Given pattern file `2.pattern`:

```
line 1 [0-9]+\.[0-9]+s
line 2
line 3
line 4
```

and output file `2.output`:

```
line 1 25.63s
line 2
line 3
line 3b extra
line 4
```

the output of `diff 2.pattern 2.output` is:

```
% diff 2.pattern 2.output
1c1
< line 1 [0-9]+\.[0-9]+s
---
> line 1 25.63s
3a4
> line 3b extra
```

and filtered with `awk -f check_pattern.awk` the only output is the extra line `line 3b extra`:

```
% diff 2.pattern 2.output | awk -f check_pattern.awk
3a4
> line 3b extra
```

or filtered with `python pyrediff.py`:

```
% diff 2.pattern 2.output | python pyrediff.py
3a4
> line 3b extra
```

### Example 3: pyre (?P<group>) and \g<group>])

Given pattern file `3.pattern`:

```
pid (?P<Pid>\d+) again=(?P=Pid)
second
third,\g<Pid>\g<Pid>
```

and output file `3.output` created with:

```
% ( echo "pid $$ again=$$"; echo "second"; echo "third,$$$$" ) > 3.output

% cat 3.output
pid 2211 again=2211
second
third,22112211
```

and filtered with `python pyrediff.py`:

```
% diff 3.pattern 3.output | python pyrediff.py
```

There is no output because pattern line `third,\g<Pid>\g<Pid>` matches the value of named group `Pid` captured from the `(?P<Pid>\d+)` in the first pattern.

Copyright
---------

Copyright (c) 2013-2015 Luke Mewburn <luke@mewburn.net>

Copying and distribution of this file, with or without modification,
are permitted in any medium without royalty provided the copyright
notice and this notice are preserved.  This file is offered as-is,
without any warranty.
