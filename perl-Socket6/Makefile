#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=perl-Socket6
PKG_VERSION:=0.28
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://www.cpan.org/authors/id/U/UM/UMEMOTO
PKG_SOURCE:=Socket6-$(PKG_VERSION).tar.gz
PKG_HASH:=bfd49ab99f3197c99285fed4683c4edc06277c1e4453f593e694d7bff0974586

PKG_LICENSE:=BSD
PKG_MAINTAINER:=Hajimu UMEMOTO <ume@mahoroba.org>

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
