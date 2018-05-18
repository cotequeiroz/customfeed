#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mrtg
PKG_VERSION:=2.17.4
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://oss.oetiker.ch/mrtg/pub
PKG_HASH:=5efa7fae8040159208472e5f889be5b41d8c8a2ea6b31616f0f75cc7f48d2365

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING COPYRIGHT

include $(INCLUDE_DIR)/package.mk

define Package/mrtg
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+perlbase-findbin +perlbase-getopt +perlbase-math +perlbase-pod +perl-SNMP_Session +perl-Socket6 +libgd
  TITLE:=A tool to monitor the traffic load on network-links
  URL:=http://oss.oetiker.ch/mrtg/
endef

define Package/mrtg/description
  MRTG will monitor SNMP network devices and draw pretty pictures showing how much 
  traffic has passed through each interface.
endef

CONFIGURE_ARGS += mr_cv_long_long_format_specifier=%lld

define Build/Prepare
	$(Build/Prepare/Default)
	rm $(PKG_BUILD_DIR)/lib/mrtg2/{SNMP_{Session,util},BER}.pm
endef

define Package/mrtg/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/{cfgmaker,indexmaker,mrtg,mrtg-traffic-sum,rateup} $(1)/usr/bin/
	sed -i -e "s<^#! $(STAGING_DIR_HOST)<#! /usr<" $(1)/usr/bin/{cfgmaker,indexmaker,mrtg}
	$(INSTALL_DIR) $(1)/usr/lib/mrtg2/Pod
	$(CP) $(PKG_BUILD_DIR)/lib/mrtg2/*.pm $(1)/usr/lib/mrtg2
	$(CP) $(PKG_BUILD_DIR)/lib/mrtg2/Pod/*.pm $(1)/usr/lib/mrtg2/Pod
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/mrtg.init $(1)/etc/init.d/mrtg
	$(INSTALL_DIR) $(1)/etc/mrtg
	$(CP) ./files/daemon.cfg $(1)/etc/mrtg
endef

$(eval $(call BuildPackage,mrtg))
