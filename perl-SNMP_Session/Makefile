#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-SNMP_Session
PKG_VERSION:=1.13
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://dev.gentoo.org/~dilfridge/distfiles/
PKG_SOURCE:=SNMP_Session-$(PKG_VERSION).tar.gz
PKG_HASH:=a1c6cf5a8893447ab5a6dc38d5bb04b5d492acabb1f282559f9d76b61272ab5f

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=Artistic-2
PKG_LICENSE_FILES:=Artistic

PKG_BUILD_DIR:=$(BUILD_DIR)/perl/SNMP_Session-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/perl/perlmod.mk

define Package/perl-SNMP_Session
  SUBMENU:=Perl
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=SNMP support for Perl 5
  URL:=https://github.com/sleinen/snmp-session
  DEPENDS:=perl +perlbase-essential +perl-Socket6 +perlbase-socket
endef

define Build/Configure
        $(call perlmod/Configure,,)
endef

define Build/Compile
        $(call perlmod/Compile,,)
endef

define Package/perl-SNMP_Session/install
        $(call perlmod/Install,$(1),BER.pm SNMP_Session.pm SNMP_util.pm)
endef


$(eval $(call BuildPackage,perl-SNMP_Session))
