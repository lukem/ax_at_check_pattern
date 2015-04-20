# SYNOPSIS
#
#   AX_AT_CHECK_PYREDIFF(COMMANDS, [STATUS], [STDOUT-RE], [STDERR-RE], [RUN-IF-FAIL], [RUN-IF-PASS])
#   AX_AT_DIFF_PYRE(PATTERN-FILE, TEST-FILE, [STATUS=0], [DIFFERENCES])
#   AX_AT_DATA_PYREDIFF_PY(FILENAME)
#
# DESCRIPTION
#
#   AX_AT_CHECK_PYREDIFF() executes a test similar to AT_CHECK(), except
#   that stdout and stderr are python regular expressions (REs).
#
#   NOTE: as autoconf uses [] for quoting, the use of [brackets] in the RE
#   arguments STDOUT-RE and STDERR-RE can be awkward and require careful
#   extra quoting, or quadrigraphs '@<:@' (for '[') and '@:>@' (for ']').
#
#   python is invoked via $PYTHON, which defaults to "python" if unset or empty.
#
#   Implemented using AT_CHECK() with a custom value for $at_diff that
#   invokes diff with a python post-processor.
#
#
#   AX_AT_DIFF_PYRE() checks that the PATTERN-FILE applies to TEST-FILE.
#   If there are differences, STATUS will be 1 and they should be DIFFERENCES.
#
#
#   AX_AT_DATA_PYREDIFF_PY() creates FILENAME with the contents of
#   the python script used.
#
#
#   The latest version of this macro and a supporting test suite are at:
#   https://github.com/lukem/ax_at_check_pattern
#
#
# LICENSE
#
#   Copyright (c) 2013-2015 Luke Mewburn <luke@mewburn.net>
#
#   Copying and distribution of this file, with or without modification,
#   are permitted in any medium without royalty provided the copyright
#   notice and this notice are preserved.  This file is offered as-is,
#   without any warranty.

#serial 1

m4_define([_AX_AT_CHECK_PYREDIFF],
[[import re
import sys

class Pyrediff:
    def __init__(self):
        self.apat = re.compile("^\d+(,\d+)?@<:@ad@:>@\d+(,\d+)?@S|@")
        self.cpat = re.compile("^\d+(,\d+)?@<:@c@:>@\d+(,\d+)?@S|@")
        self.rv = 0
        self.setmode()

    def pyrediff(self, input):
        for line in input:
            line = line.rstrip("\n")
            if self.apat.match(line):
                print line
                self.setmode()
                self.rv = 1
            elif self.cpat.match(line):
                self.setmode(line)
            elif not self.mode:
                print line
            elif line.startswith("< "):
                self.ll.append(line)
            elif "---" == line:
                pass
            elif line.startswith("> "):
                self.rl.append(line)
                if len(self.rl) > len(self.ll):
                    self.mismatch()
                else:
                    pat = "^" + self.ll@<:@-1@:>@@<:@2:@:>@ + "@S|@"
                    str = line@<:@2:@:>@
                    if not re.match(pat, str):
                        self.mismatch()
            else:
                print "UNEXPECTED LINE: %s" % line
                return 10
        return self.rv

    def mismatch(self):
        print self.mode
        print "\n".join(self.ll)
        print "---"
        print "\n".join(self.rl)
        self.setmode()
        self.rv = 1

    def setmode(self, mode=None):
        self.mode = mode
        self.ll = @<:@@:>@
        self.rl = @<:@@:>@

if "__main__" == __name__:
    pd = Pyrediff()
    sys.exit(pd.pyrediff(sys.stdin))
]])


m4_defun([_AX_AT_CHECK_PYRE_PREPARE], [dnl
dnl Can't use AM_PATH_PYTHON() in autotest.
AS_VAR_IF([PYTHON], [], [PYTHON=python])

AS_REQUIRE_SHELL_FN([ax_at_diff_pyre],
  [AS_FUNCTION_DESCRIBE([ax_at_diff_pyre], [PATTERN OUTPUT],
    [Diff PATTERN OUTPUT and elide change lines where the RE pattern matches])],
[diff "$[]1" "$[]2" | $PYTHON -c '_AX_AT_CHECK_PYREDIFF'])
])dnl _AX_AT_CHECK_PYRE_PREPARE


m4_defun([AX_AT_CHECK_PYREDIFF], [dnl
AS_REQUIRE([_AX_AT_CHECK_PYRE_PREPARE])
_ax_at_check_pattern_prepare_original_at_diff="$at_diff"
at_diff='ax_at_diff_pyre'
AT_CHECK(m4_expand([$1]), [$2], m4_expand([$3]), m4_expand([$4]),
        [at_diff="$_ax_at_check_pattern_prepare_original_at_diff";$5],
        [at_diff="$_ax_at_check_pattern_prepare_original_at_diff";$6])

])dnl AX_AT_CHECK_PYREDIFF


m4_defun([AX_AT_DIFF_PYRE], [dnl
AS_REQUIRE([_AX_AT_CHECK_PYRE_PREPARE])
AT_CHECK([ax_at_diff_pyre $1 $2], [$3], [$4])
])dnl AX_AT_DIFF_PYRE


m4_defun([AX_AT_DATA_PYREDIFF_PY], [dnl
m4_if([$1], [], [m4_fatal([$0: argument 1: empty filename])])
AT_DATA($1, [dnl
#!/usr/bin/env python
#
# check_pyre.py
# Generated by AX_AT_DATA_PYREDIFF_PY@{:@@:}@
# from https://github.com/lukem/ax_at_check_pattern
#
# python script to process the output of "diff PATTERN OUTPUT" removing lines
# where the difference is a PATTERN line that exactly matches an OUTPUT line.
# 
]
_AX_AT_CHECK_PYREDIFF)
])dnl AX_AT_DATA_PYREDIFF_PY
