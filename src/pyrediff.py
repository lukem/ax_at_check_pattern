#!/usr/bin/env python
#
# pyrediff.py
# Generated by AX_AT_DATA_PYREDIFF_PY()
# from https://github.com/lukem/ax_at_check_pattern
#
# python script to process the output of "diff PYRE OUTPUT" removing lines
# where the difference is a PYRE line that exactly matches an OUTPUT line.
#

import re
import sys

class Pyrediff:
    apat = re.compile("^\d+(,\d+)?[ad]\d+(,\d+)?$")
    cpat = re.compile("^\d+(,\d+)?[c]\d+(,\d+)?$")

    def diff(self, input):
        self.fail = False
        self.set_mode()
        for line in input:
            self.diff_line(line.rstrip("\n"))
        return self.fail

    def diff_line(self, line):
        if self.apat.match(line):
            print line
            self.set_mode()
            self.fail = True
        elif self.cpat.match(line):
            self.set_mode(line)
        elif self.mode is None:
            print line
        elif line.startswith("< "):
            self.patlines.append(line)
        elif "---" == line:
            pass
        elif line.startswith("> "):
            self.strlines.append(line)
            if len(self.strlines) > len(self.patlines):
                self.mismatch()
            else:
                pat = self.patlines[len(self.strlines)-1][2:]
                str = line[2:]
                match = re.search("^%s$" % pat, str)
                if match is None:
                    self.mismatch()
        else:
            raise NotImplementedError("unexpected line=%r" % line)

    def mismatch(self):
        print self.mode
        print "\n".join(self.patlines)
        print "---"
        print "\n".join(self.strlines)
        self.set_mode()
        self.fail = True

    def set_mode(self, mode=None):
        self.mode = mode
        self.patlines = []
        self.strlines = []

if "__main__" == __name__:
    if Pyrediff().diff(sys.stdin):
        sys.exit(1)
