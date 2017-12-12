#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=protobuf-3.1
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PKG_SOURCE:=protobuf-cpp-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/google/protobuf/releases/download/v$(PKG_VERSION)
PKG_HASH:=51ceea9957c875bdedeb1f64396b5b0f3864fe830eed6a2d9c066448373ea2d6

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=protobuf-3.1/host
PKG_USE_MIPS16:=0# MIPS16 prevents protobuf's usage of the 'sync' asm-opcode

PKG_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/protobuf-$(PKG_VERSION)
HOST_BUILD_DIR=$(BUILD_DIR_HOST)/protobuf-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/protobuf-3.1
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Version 3.1.0 of Google's structured data encoding library
  URL:=https://github.com/google/protobuf
  DEPENDS:=+zlib +libpthread +libstdcpp
  MAINTAINER:=Per Sandström <per.j.sandstrom@gmail.com>
endef

define Package/protobuf-3.1/description
 Protocol Buffers are a way of encoding structured data in an efficient
 yet extensible format. Google uses Protocol Buffers for almost all
 of its internal RPC protocols and file formats.
endef

CONFIGURE_ARGS += --with-protoc=$(STAGING_DIR_HOSTPKG)/bin/protoc-3.1

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(CP) $(HOST_BUILD_DIR)/src/.libs/protoc $(STAGING_DIR_HOSTPKG)/bin/protoc-3.1

	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/lib/protobuf-3.1
	$(CP) $(HOST_BUILD_DIR)/src/.libs/lib*.so* $(STAGING_DIR_HOSTPKG)/lib/protobuf-3.1
	$(CP) $(HOST_BUILD_DIR)/src/.libs/lib*.so.* $(STAGING_DIR_HOSTPKG)/lib
	for f in libprotobuf libprotobuf-lite libprotoc; do \
		$(LN) -s protobuf-3.1/$$$$f.so $(STAGING_DIR_HOSTPKG)/lib/$$$$f-3.1.so ; \
		$(CP) $(HOST_BUILD_DIR)/src/.libs/$$$$f.a $(STAGING_DIR_HOSTPKG)/lib/protobuf-3.1 ; \
		$(CP) $(HOST_BUILD_DIR)/src/.libs/$$$$f.lai $(STAGING_DIR_HOSTPKG)/lib/$$$$f-3.1.la ; \
		sed -i -e "s=\(libproto[^.]\+\)\(\.\(l\?a\|so\([^.]\|\$\)\)\)=\1-3.1\2=g" \
			$(STAGING_DIR_HOSTPKG)/lib/$$$$f-3.1.la ; \
	done
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/lib/protobuf-3.1 \
		$(1)/usr/include/protobuf-3.1

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/protobuf-3.1/

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.a \
		$(1)/usr/lib/protobuf-3.1

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so* \
		$(1)/usr/lib/protobuf-3.1

	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.so.* \
		$(1)/usr/lib

	for f in libprotobuf libprotobuf-lite libprotoc; do \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/$$$$f.a $(1)/usr/lib/$$$$f-3.1.a ; \
		$(CP) $(PKG_INSTALL_DIR)/usr/lib/$$$$f.so  $(1)/usr/lib/$$$$f-3.1.so ; \
	done
endef

define Package/protobuf-3.1/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	for f in libprotobuf libprotobuf-lite libprotoc; do \
		$(CP) \
			$(PKG_INSTALL_DIR)/usr/lib/$$$$f.so.*  \
			$(1)/usr/lib ; \
	done
endef

$(eval $(call BuildPackage,protobuf-3.1))
$(eval $(call HostBuild))
