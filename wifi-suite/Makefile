#
# Copyright (C) 2024 Eneas U de Queiroz
#
# SPDX-License-Identifiere: GPL-2.0-or-later
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-suite
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/wifi-scripts
  SECTION:=utils
  CATEGORY:=Base system
  DEPENDS:=+hostapd_cli
  TITLE:=Displays Wi-Fi clients's AKM suite
  PKGARCH:=all
endef

define Package/qos-scripts/description
 A script that shows the currently connected clients and their AKM suites.
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/wifi-suite/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) ./files/* $(1)/usr/bin
endef

$(eval $(call BuildPackage,wifi-suite))
