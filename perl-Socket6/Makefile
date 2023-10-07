#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-Socket6
PKG_VERSION:=0.29
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/U/UM/UMEMOTO
PKG_SOURCE:=Socket6-$(PKG_VERSION).tar.gz
PKG_HASH:=468915fa3a04dcf6574fc957eff495915e24569434970c91ee8e4e1459fc9114

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=README
PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/Socket6-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/perl/perlmod.mk

define Package/perl-Socket6
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=IPv6 related part of the C socket.h defines and structure manipulators
  URL:=http://search.cpan.org/dist/Socket6/
  DEPENDS:=perl +perlbase-essential +perlbase-socket
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-Socket6/install
	$(call perlmod/Install,$(1),Socket6.pm auto/Socket6,)
endef


$(eval $(call BuildPackage,perl-Socket6))
