#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openssl-1.1
PKG_BASE:=1.1.0
PKG_BUGFIX:=g
PKG_VERSION:=$(PKG_BASE)$(PKG_BUGFIX)
PKG_RELEASE:=1
PKG_USE_MIPS16:=0

PKG_BUILD_PARALLEL:=0

PKG_BUILD_DIR=$(BUILD_DIR)/openssl-$(PKG_VERSION)

PKG_SOURCE:=openssl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.openssl.org/source/ \
	ftp://ftp.openssl.org/source/ \
	http://www.openssl.org/source/old/$(PKG_BASE)/ \
	ftp://ftp.funet.fi/pub/crypt/mirrors/ftp.openssl.org/source \
	ftp://ftp.sunet.se/pub/security/tools/net/openssl/source/
PKG_HASH:=de4d501267da39310905cb6dc8c6121f7a2cad45a7707f76df828fe1b85073af

PKG_LICENSE:=OpenSSL
PKG_LICENSE_FILES:=LICENSE
PKG_CONFIG_DEPENDS:= \
	CONFIG_OPENSSL_ENGINE_CRYPTO \
	CONFIG_OPENSSL_ENGINE_DIGEST \
	CONFIG_OPENSSL_HARDWARE_SUPPORT

include $(INCLUDE_DIR)/package.mk

# ifneq ($(CONFIG_CCACHE),)
#HOSTCC=$(HOSTCC_NOCACHE)
#HOSTCXX=$(HOSTCXX_NOCACHE)
#endif

define Package/openssl-1.1/Default
  TITLE:=Open source SSL toolkit v. 1.1
  URL:=http://www.openssl.org/
endef

define Package/openssl-1.1/Default/description
The OpenSSL Project is a collaborative effort to develop a robust,
commercial-grade, full-featured, and Open Source toolkit implementing the
Transport Layer Security (TLS v1-v1.2) protocols as well
as a full-strength general purpose cryptography library.
Version 1.1 makes wholesale changes at the API and is
currently not compatible with many packages, so it is being
packaged separately.
endef

define Package/libopenssl-1.1
  $(call Package/openssl-1.1/Default)
  SECTION:=libs
  SUBMENU:=SSL
  CATEGORY:=Libraries
  DEPENDS:=+zlib
  TITLE+= (libraries)
  ABI_VERSION:=$(PKG_VERSION)
endef

define Package/libopenssl-1.1/description
$(call Package/openssl-1.1/Default/description)
This package contains the OpenSSL shared libraries, needed by other programs.
endef

define Package/openssl-1.1-util
  $(call Package/openssl-1.1/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libopenssl-1.1
  TITLE+= (utility)
endef

define Package/openssl-1.1-util/description
$(call Package/openssl-1.1/Default/description)
This package contains the OpenSSL v 1.1 command-line utility.
endef

OPENSSL_NO_CIPHERS:= no-idea no-md2 no-mdc2 no-rc5 no-camellia
OPENSSL_OPTIONS:= shared no-err zlib-dynamic no-sse2

ifdef CONFIG_OPENSSL_ENGINE_CRYPTO
  OPENSSL_OPTIONS += -DHAVE_CRYPTODEV
  ifdef CONFIG_OPENSSL_ENGINE_DIGEST
    OPENSSL_OPTIONS += -DUSE_CRYPTODEV_DIGESTS
  endif
else
  OPENSSL_OPTIONS += no-engine
endif

ifndef CONFIG_OPENSSL_HARDWARE_SUPPORT
  OPENSSL_OPTIONS += no-hw
endif

ifeq ($(CONFIG_x86_64),y)
  OPENSSL_TARGET:=linux-x86_64-openwrt
  OPENSSL_MAKEFLAGS += LIBDIR=lib
else
  OPENSSL_OPTIONS+=no-sse2
  ifeq ($(CONFIG_mips)$(CONFIG_mipsel),y)
    OPENSSL_TARGET:=linux-mips32-openwrt
  else ifeq ($(CONFIG_arm)$(CONFIG_armeb),y)
    OPENSSL_TARGET:=linux-armv4-openwrt
  else
    OPENSSL_TARGET:=linux-generic-openwrt
    OPENSSL_OPTIONS+=no-perlasm
  endif
endif

STAMP_CONFIGURED := $(STAMP_CONFIGURED)_$(subst $(space),_,$(OPENSSL_OPTIONS))

define Build/Configure
	[ -f $(STAMP_CONFIGURED) ] || { \
		rm -f $(PKG_BUILD_DIR)/*.so.* $(PKG_BUILD_DIR)/*.a; \
		find $(PKG_BUILD_DIR) -name \*.o | xargs rm -f; \
	}
	(cd $(PKG_BUILD_DIR); \
		./Configure $(OPENSSL_TARGET) \
			--prefix=/usr \
			--openssldir=/etc/ssl \
			$(TARGET_CPPFLAGS) \
			$(TARGET_LDFLAGS) -ldl \
			-DOPENSSL_SMALL_FOOTPRINT \
			-DOPENSSL_NO_ASYNC \
			$(OPENSSL_NO_CIPHERS) \
			$(OPENSSL_OPTIONS) \
	)
	# XXX: OpenSSL "make depend" will look for installed headers before its own,
	# so remove installed stuff first
	-$(SUBMAKE) -j1 clean-staging
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		MAKEDEPPROG="$(TARGET_CROSS)gcc" \
		OPENWRT_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		$(OPENSSL_MAKEFLAGS) \
		depend
endef

TARGET_CFLAGS += $(FPIC) -I$(CURDIR)/include

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		ASFLAGS="$(TARGET_ASFLAGS) -I$(PKG_BUILD_DIR)/crypto -c" \
		AR="$(TARGET_CROSS)ar r" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		OPENWRT_OPTIMIZATION_FLAGS="$(TARGET_CFLAGS)" \
		$(OPENSSL_MAKEFLAGS) \
		all
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		$(OPENSSL_MAKEFLAGS) \
		install_sw
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/openssl-1.1/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/openssl $(1)/usr/include/openssl-1.1/
	$(INSTALL_DIR) $(1)/usr/lib/openssl-1.1/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{crypto,ssl}.{a,so*} $(1)/usr/lib/openssl-1.1/
#	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
#	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/{openssl,libcrypto,libssl}.pc $(1)/usr/lib/pkgconfig/
#	[ -n "$(TARGET_LDFLAGS)" ] && $(SED) 's#$(TARGET_LDFLAGS)##g' $(1)/usr/lib/pkgconfig/{openssl,libcrypto,libssl}.pc || true
endef

define Package/libopenssl-1.1/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libcrypto.so.* $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libssl.so.* $(1)/usr/lib/
endef

define Package/openssl-1.1-util/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/openssl $(1)/usr/bin/openssl-1.1
endef

$(eval $(call BuildPackage,libopenssl-1.1))
$(eval $(call BuildPackage,openssl-1.1-util))
