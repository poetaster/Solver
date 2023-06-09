import sys
import platform
import threading
from enum import Enum, IntEnum, unique

(major, minor, micro, release, serial) = sys.version_info
sys.path.append("/usr/share/harbour-fibonacci/lib/python" + str(major) + "." + str(minor) + "/site-packages/");

import pyotherside
from platform import python_version

timet1=time.time()

from sympy import *
from sympy import __version__
from sympy.interactive.printing import init_printing
from sympy.printing.mathml import print_mathml

timet2=time.time()
loadingtimeSymPy = timet2-timet1

versionPython = python_version()
versionSymPy = __version__

simplifyType = {'none':0, 'expandterms':1, 'simplifyterms':2, 'expandall':3, \
                'simplifyall':4}

outputType = {'simple':0, 'bidimensional':1, 'latex':2, 'c':3, \
              'fortran':4, 'javascript':5, 'python':6}

import derivative
import integral
import limit
