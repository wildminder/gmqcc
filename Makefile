# =========================================================================
# gmqcc Compiler Makefile
#
# This Makefile is designed to be both:
# 1. A standalone build system.
# 2. An integrable component that respects configuration from a parent.
#
# All configuration uses the '?=' operator, allowing variables like CXX,
# DEBUG, etc., to be overridden by the calling environment.
# =========================================================================


# Compilation options:
# * LTO       - Link time optimization       [default=0]
# * ASAN      - Address sanitizer            [default=0]
# * UBSAN     - Undefined behavior sanitizer [default=0]
# * DEBUG     - Debug build                  [default=0]
# * UNUSED    - Remove unused references     [default=1]
# * SRCDIR    - Out of tree builds           [default=./]
LTO ?= 0
ASAN ?= 0
UBSAN ?= 0
DEBUG ?= 0
UNUSED ?= 1
SRCDIR ?= ./

# Toolchain (can be overridden)
CXX ?= g++

# Build Artifacts
EXE_EXT :=
ifeq ($(OS),Windows_NT)
	EXE_EXT := .exe
endif

# Binaries are placed in the current directory.
# Object files are kept in a local .build/ directory.
GMQCC := gmqcc$(EXE_EXT)
QCVM := qcvm$(EXE_EXT)
TESTSUITE := testsuite$(EXE_EXT)


OBJDIR := .build/objs
DEPDIR := .build/deps

# On Windows, don't try to build the testsuite, which has Unix dependencies.
ifeq ($(OS),Windows_NT)
	TARGETS := $(GMQCC) $(QCVM)
else
	TARGETS := $(GMQCC) $(QCVM) $(TESTSUITE)
endif

# Collect all the source files for GMQCC.
GSRCS := ast.cpp
GSRCS += code.cpp
GSRCS += conout.cpp
GSRCS += fold.cpp
GSRCS += ftepp.cpp
GSRCS += intrin.cpp
GSRCS += ir.cpp
GSRCS += lexer.cpp
GSRCS += main.cpp
GSRCS += opts.cpp
GSRCS += parser.cpp
GSRCS += stat.cpp
GSRCS += utf8.cpp
GSRCS += util.cpp


# Collect all the source files for QCVM.
QSRCS := exec.cpp
#QSRCS += conout.cpp
#QSRCS += opts.cpp
QSRCS += stat.cpp
QSRCS += util.cpp

# Collect all the source files for TESTSUITE.
TSRCS := conout.cpp
TSRCS += opts.cpp
TSRCS += stat.cpp
TSRCS += test.cpp
TSRCS += util.cpp

#
# Compilation flags
#
CXXFLAGS := -Wall
CXXFLAGS += -Wextra
CXXFLAGS += -Wno-parentheses
CXXFLAGS += -Wno-class-memaccess
CXXFLAGS += -Wno-implicit-fallthrough
CXXFLAGS += -std=c++11
# Disable some unneeded features.
CXXFLAGS += -fno-exceptions
CXXFLAGS += -fno-rtti
CXXFLAGS += -fno-asynchronous-unwind-tables

# Give each function and data it's own section so the linker can remove unused
# references to each, producing smaller, tighter binaries.
ifeq ($(UNUSED),1)
	CXXFLAGS += -ffunction-sections
	CXXFLAGS += -fdata-sections
endif

# Enable link-time optimizations if requested.
ifeq ($(LTO),1)
	CXXFLAGS += -flto
endif

ifeq ($(DEBUG),1)
	# Ensure there is a frame-pointer in debug builds.
	CXXFLAGS += -fno-omit-frame-pointer

	# Disable all optimizations in debug builds.
	CXXFLAGS += -O0

	# Enable debug symbols.
	CXXFLAGS += -g
else
	# Disable all the stack protection features in release builds.
	CXXFLAGS += -fno-stack-protector
	CXXFLAGS += -fno-stack-check

	# Disable frame pointer in release builds when AddressSanitizer isn't present.
	ifeq ($(ASAN),1)
		CXXFLAGS += -fno-omit-frame-pointer
	else
		CXXFLAGS += -fomit-frame-pointer
	endif
	# Highest optimization flag in release builds.
	CXXFLAGS += -O3
endif

# Sanitizer selection
ifeq ($(ASAN),1)
	CXXFLAGS += -fsanitize=address
endif
ifeq ($(UBSAN),1)
	CXXFLAGS += -fsanitize=undefined
endif

#
# Dependency flags
#
DEPFLAGS := -MMD
DEPFLAGS += -MP

#
# Linker flags
#
LDFLAGS :=

# Remove unreferenced sections
ifeq ($(UNUSED),1)
	LDFLAGS += -Wl,--gc-sections
endif

# Enable link-time optimizations if request.
ifeq ($(LTO),1)
	LDFLAGS += -flto
endif

# Sanitizer selection
ifeq ($(ASAN),1)
	LDFLAGS += -fsanitize=address
endif
ifeq ($(UBSAN),1)
	LDFLAGS += -fsanitize=undefined
endif

# Stripper
# Default to `strip` unless it's a debug build. Can be overridden by parent.
ifneq (,$(findstring -g,$(CXXFLAGS)))
	STRIP ?= /bin/true # A command that does nothing
else
	STRIP ?= strip
endif

# Main Targets
.PHONY: all test clean

all: $(TARGETS)

# Create build directories if they don't exist.
# Build artifact directories.
$(DEPDIR):
	@mkdir -p $(DEPDIR)
$(OBJDIR):
	@mkdir -p $(OBJDIR)


# Rule to compile a .cpp file into a .o file and generate a dependency file.
# Note the use of $(SRCDIR) to correctly find sources.
$(OBJDIR)/%.o: $(SRCDIR)%.cpp | $(OBJDIR) $(DEPDIR)
	@echo "Compiling $<"
	$(CXX) -MT $@ $(DEPFLAGS) -MF $(DEPDIR)/$*.Td $(CXXFLAGS) -c -o $@ $<
	@mv -f $(DEPDIR)/$*.Td $(DEPDIR)/$*.d

# Linking Targets
$(GMQCC): $(GSRCS:%.cpp=$(OBJDIR)/%.o)
	@echo "Linking $@"
	$(CXX) $^ $(LDFLAGS) -o $@
	$(STRIP) $@

$(QCVM): $(QSRCS:%.cpp=$(OBJDIR)/%.o)
	@echo "Linking $@"
	$(CXX) $^ $(LDFLAGS) -o $@
	$(STRIP) $@

$(TESTSUITE): $(TSRCS:%.cpp=$(OBJDIR)/%.o)
	@echo "Linking $@"
	$(CXX) $^ $(LDFLAGS) -o $@
	$(STRIP) $@

# Utility Targets
test: $(QCVM) $(TESTSUITE)
ifeq ($(OS),Windows_NT)
	@echo "Testsuite is not supported on Windows."
else
	@./$(TESTSUTIE)
endif

clean:
	@echo "Cleaning gmqcc artifacts..."
	@rm -rf $(DEPDIR) $(OBJDIR) $(GMQCC) $(QCVM) $(TESTSUITE)

# Include all generated dependency files.
-include $(wildcard $(DEPDIR)/*.d)