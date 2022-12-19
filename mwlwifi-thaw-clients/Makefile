# Copyright (C) 2021 Eneas Ulir de Queiroz <cotequeiroz@gmail.com>
# SPDX-License-Identifiere: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=kmod-mwlwifi-thaw-clients
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=GPL-2-or-later

include $(INCLUDE_DIR)/package.mk

define Package/kmod-mwlwifi-thaw-clients
  CATEGORY:=Kernel modules
  SECTION:=kernel
  SUBMENU:=Wireless Drivers
  TITLE:=mwlwifi thaw clients workaround utility
  DEPENDS:=kmod-mwlwifi +hostapd-utils
endef

define Package/openssl/Default/description
This is a script that works around a bug in mwlwifi that causes
some clients to lose connectivity.
It looks for Rekeying PTK messages from the kernel, and disassociates
the client mentioned in the message from all interfaces. This
forces the client to reconnect, restoring connectivity.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

Build/Configure=
Build/Compile=

define Package/kmod-mwlwifi-thaw-clients/install
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,kmod-mwlwifi-thaw-clients))
