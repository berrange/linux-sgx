#
# Copyright (C) 2011-2021 Intel Corporation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#   * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#   * Neither the name of Intel Corporation nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#

TOP_DIR  = ../../..
include $(TOP_DIR)/buildenv.mk

AESM_CONFIG := -DBUILD_SHARED_LIBS=ON -DUS_BUILD_SHARED_LIBS=ON
CPPMICROSERVICES_CONFIG := -DCMAKE_INSTALL_PREFIX=$(CPPMICROSERVICES_INSTALL_DIR) -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS= -DCMAKE_CXX_FLAGS= -DFORTIFY_SOURCE_VAL=$(FORTIFY_SOURCE_VAL)
ifdef DEBUG
    AESM_CONFIG += -DCMAKE_BUILD_TYPE=Debug
else
     AESM_CONFIG += -DCMAKE_BUILD_TYPE=Release
endif

ifeq ($(BUILD_REF_LE), 1)
     AESM_CONFIG += -DREF_LE=ON
endif

AESM_CONFIG += -DOPENSSL_CRYPTO_CFLAGS=$(OPENSSL_CRYPTO_CFLAGS)
AESM_CONFIG += -DOPENSSL_CRYPTO_LIBS=$(OPENSSL_CRYPTO_LIBS)
AESM_CONFIG += -DCPPMICROSERVICES_CMAKE_DIR=$(CPPMICROSERVICES_CMAKE_DIR)

ifeq ($(ARCH), x86)
    SQLITECFLAGS += -m32
else
    SQLITECFLAGS += -m64
endif

ifdef PROFILE
    CXXFLAGS += -D_PROFILE_
    CFLAGS += -D_PROFILE_
endif

CXXFLAGS += -fpie
CFLAGS += -fpie
CFLAGS := $(filter-out -Werror, $(CFLAGS))

WHITE_LIST_FILE := $(LINUX_PSW_DIR)/ae/data/prebuilt/white_list_cert_to_be_verify.bin
APPNAME         := source/build/bin/aesm_service
ifeq ($(USE_HOST_CPPMICROSERVICES), 0)
CPPMICROSERVICES:= $(CPPMICROSERVICES_SRC_DIR)/build/lib/libCppMicroServices.so.4.0.0
endif
RDRAND_LIBDIR :=$(LINUX_EXTERNAL_DIR)/rdrand/src
RDRAND_MAKEFILE := $(RDRAND_LIBDIR)/Makefile

.PHONY: all
all: $(APPNAME) $(APPNAME_DEBUG) copy_data_file | $(BUILD_DIR)
	$(CP) -r source/build/bin/* $|

copy_data_file:
	@$(MKDIR) -p data
	@$(CP) $(WHITE_LIST_FILE) data/white_list_cert_to_be_verify.bin

$(APPNAME): $(CPPMICROSERVICES) source/build/CMakeCache.txt urts RDRAND
	$(MAKE) -C source/build VERBOSE=1
ifeq ($(USE_HOST_CPPMICROSERVICES), 0)
	$(CP) $(CPPMICROSERVICES) source/build/bin/
endif

CMAKE_VERSION_MAJOR=$(shell cmake --version | head -n  1 | cut -d \  -f 3 | cut -d . -f 1)
CMAKE_VERSION_MINOR=$(shell cmake --version | head -n  1 | cut -d \  -f 3 | cut -d . -f 2 | xargs printf '%02d')
CMAKE_VERSION=$(CMAKE_VERSION_MAJOR)$(CMAKE_VERSION_MINOR)
CMAKE := $(HOME)/cache/bin/cmake

ifeq ($(USE_HOST_CPPMICROSERVICES), 0)
.PHONY: CPPMICROSERVICES
$(CPPMICROSERVICES):
	mkdir -p $(CPPMICROSERVICES_SRC_DIR)/build
ifeq ($(shell test $(CMAKE_VERSION) -lt 302 && echo 1), 1)
	$(CPPMICROSERVICES_SRC_DIR)/install_cmake.sh
	cd $(CPPMICROSERVICES_SRC_DIR)/build && $(CMAKE) -DCMAKE_COMMAND=$(CMAKE) $(CPPMICROSERVICES_CONFIG) ../ && $(MAKE) && $(MAKE) install
else
	cd $(CPPMICROSERVICES_SRC_DIR)/build && cmake $(CPPMICROSERVICES_CONFIG) ../ && $(MAKE) && $(MAKE) install
endif
endif

source/build/CMakeCache.txt: $(CPPMICROSERVICES)
ifeq ($(shell test $(CMAKE_VERSION) -lt 300 && echo 1), 1)
	mkdir -p source/build && cd source/build && $(CMAKE) -DCMAKE_COMMAND=$(CMAKE) $(AESM_CONFIG) ../
else
	mkdir -p source/build && cd source/build && cmake $(AESM_CONFIG) ../
endif

RDRAND: $(RDRAND_MAKEFILE)
	$(MAKE) -C $(RDRAND_LIBDIR)

$(RDRAND_MAKEFILE):
ifeq ($(ARCH), x86)
	@cd $(RDRAND_LIBDIR);./configure
else
	@cd $(RDRAND_LIBDIR);./configure CFLAGS=-fPIC
endif

.PHONY: urts
urts:
	$(MAKE) -C $(LINUX_PSW_DIR)/urts/linux

$(BUILD_DIR):
	@$(MKDIR) $@

.PHONY: clean
clean:
	@$(RM) -r source/build
ifeq ($(USE_HOST_CPPMICROSERVICES), 0)
	@$(RM) -r $(CPPMICROSERVICES_SRC_DIR)/build
	@$(RM) -r $(CPPMICROSERVICES_INSTALL_DIR)
endif
	@$(RM) -r data
ifeq ($(RDRAND_MAKEFILE), $(wildcard $(RDRAND_MAKEFILE)))
	@$(MAKE) distclean -C $(RDRAND_LIBDIR)
endif

.PHONY: rebuild
rebuild:
	$(MAKE) clean
	$(MAKE) all

