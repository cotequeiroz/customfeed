#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libtirpc
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/libtirpc
PKG_HASH:=723c5ce92706cbb601a8db09110df1b4b69391643158f20ff587e20e7c5f90f5
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Eneas Queiroz <equeiroz@troianet.com.br>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/libtirpc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Transport Independent RPC library (SunRPC replacement)
  URL:=http://libtirpc.sourceforge.net/
endef

define Package/libtirpc/description
 Libtirpc is a port of Sun's Transport-Independent RPC library to Linux.
endef

#TARGET_CFLAGS += $(FPIC) -D__bzero=bzero
TARGET_CFLAGS += -D__bzero=bzero

CONFIGURE_ARGS += \
	--disable-gssapi \
	--enable-shared \
	--disable-static \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) -R $(PKG_INSTALL_DIR)/usr/include/tirpc $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtirpc.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig
endef

define Package/libtirpc/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/doc/netconfig $(1)/etc
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtirpc.so.* $(1)/usr/lib/
endef

define Package/libtirpc/conffiles
/etc/netconfig
endef

$(eval $(call BuildPackage,libtirpc))
