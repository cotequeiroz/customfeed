#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rpcbind
PKG_VERSION:=0.2.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/rpcbind
PKG_HASH:=074a9a530dc7c11e0d905aa59bcb0847c009313f02e98d3d798aa9568f414c66

PKG_MAINTAINER:=Eneas Queiroz <equeiroz@troianet.com.br>
PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/rpcbind
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libtirpc +RPCBIND_ENABLE_LIBWRAP:libwrap
  TITLE:=RPCBind server (portmap replacement)
  URL:=https://sourceforge.net/projects/rpcbind/
  MAINTAINER:=Eneas Queiroz <equeiroz@troianet.com.br>
  USERID:=rpc=65533:rpc=65533
endef

define Package/rpcbind/description
  The rpcbind utility is a server that converts RPC program numbers 
  into universal addresses over various protocols.
endef

define Package/rpcbind/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += \
	--with-rpcuser=rpc \
	--with-systemdsystemunitdir=no

ifdef CONFIG_RPCBIND_ENABLE_LIBWRAP
	CONFIGURE_ARGS += \
		--enable-libwrap
endif

define Package/rpcbind/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpcbind $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rpcinfo $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/rpcbind.init $(1)/etc/init.d/rpcbind
endef

$(eval $(call BuildPackage,rpcbind))
