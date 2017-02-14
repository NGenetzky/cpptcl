# Copyright (c) 2011-2012 Wei Song <songw@cs.man.ac.uk> 
#    Advanced Processor Technologies Group, School of Computer Science
#    University of Manchester, Manchester M13 9PL UK
#
#    This source code is free software; you can redistribute it
#    and/or modify it in source code form under the terms of the GNU
#    General Public License as published by the Free Software
#    Foundation; either version 2 of the License, or (at your option)
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
#
# Top level Makefile
# 04/07/2012   Wei Song
#
#

#### PROJECT SETTINGS ####
# Destination directory, like a jail or mounted system
DESTDIR = /
INSTALL_PREFIX = usr/local

# Note that _LIB and _INCLUDE are directories owned by cpptcl; however, _BIN
# is assumed to be a shared directory.
DEST_BIN = $(DESTDIR)$(INSTALL_PREFIX)/bin
DEST_LIB = $(DESTDIR)$(INSTALL_PREFIX)/lib/cpptcl
DEST_INCLUDE = $(DESTDIR)$(INSTALL_PREFIX)/include/cpptcl
#### END PROJECT SETTINGS ####

# global variables
# C++ compiler
export CXX = g++

# the Tcl library
OS_NAME := $(shell uname)
# Linux
ifeq ($(OS_NAME), Linux)
  TCL_OBJ_LINKFLAG = -ltcl
  TCL_SHARED_LINKFLAG = -shared
  PIC_FLAG = -fPIC
endif

# other systems, such as MinGW
ifneq ($(findstring MinGW, $(OS_NAME)),)
  TCL_OBJ_LINKFLAG = -ltcl85 -L/usr/local/lib
  TCL_SHARED_LINKFLAG = -shared $(shell which tcl85.dll)
  PIC_FLAG =
endif

# export the flags to all sub-directories
export CXXFLAGS = -std=c++0x -Wall -Wextra -g $(PIC_FLAG)
export OBJ_LINKFLAGS = $(TCL_OBJ_LINKFLAG)
export SHARED_LINKFLAGS = $(TCL_SHARED_LINKFLAG)

# local variables
INCDIRS = -I.
HEADERS = $(wildcard ./*.h)
HEADERS += $(wildcard ./details/*.h)
HEADERS += $(wildcard ./preproc/*.hpp)

# targets
TESTDIRS = test
EXAMPLEDIRS = examples

# actions

all: cpptcl.o cpptcl.so

cpptcl.so : %.so:%.cc $(HEADERS)
	$(CXX) $(INCDIRS) $(CXXFLAGS) $(SHARED_LINKFLAGS) -c $< -o $@

cpptcl.o : %.o:%.cc $(HEADERS)
	$(CXX) $(INCDIRS) $(CXXFLAGS) -c $< -o $@

.PHONY: clean $(TESTDIRS) $(EXAMPLEDIRS)

# Installs to the set path
.PHONY: install
install: cpptcl.o cpptcl.so cpptcl.h
	mkdir -p $(DEST_LIB) $(DEST_INCLUDE)
	chmod 755 ./cpptcl.o
	cp ./cpptcl.o $(DEST_BIN)
	cp ./cpptcl.so $(DEST_LIB)
	cp ./cpptcl.h $(DEST_INCLUDE)
# Installs to the set path
.PHONY: uninstall
uninstall:
	rm  $(DEST_BIN)/cpptcl.o
	rm  -r $(DEST_LIB)
	rm  -r $(DEST_INCLUDE)

test: cpptcl.o $(TESTDIRS)

example: cpptcl.o $(EXAMPLEDIRS)

$(TESTDIRS):
	$(MAKE) -C $@

$(EXAMPLEDIRS):
	$(MAKE) -C $@

clean:
	-rm *.o
	-for d in $(EXAMPLEDIRS); do $(MAKE) -C $$d clean; done
	-for d in $(TESTDIRS); do $(MAKE) -C $$d clean; done

