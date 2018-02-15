include $(TOPDIR)/rules.mk

PKG_NAME:=ustream-ssl-openssl-1.1
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=$(LEDE_GIT)/project/ustream-ssl.git
PKG_SOURCE_DATE:=2016-07-02
PKG_SOURCE_SUBDIR=ustream-ssl-$(PKG_VERSION)
PKG_SOURCE_VERSION:=ec80adaa1b47f28d426fa19c692011ce60b992d6
PKG_MIRROR_HASH:=bfbad6b4e8c1e933f0bfaab43cbdd44a536c08128c3a779e6f2395a6a886aab7
PKG_SOURCE=ustream-ssl-$(PKG_VERSION).tar.xz
CMAKE_INSTALL:=1

PKG_BUILD_DIR=$(BUILD_DIR)/ustream-ssl-openssl-1.1/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=

PKG_MAINTAINER:=Eneas Queiroz <euqueiroz@yahoo.com.br>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libustream-openssl-1.1
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=ustream SSL Library (openssl 1.1)
  DEPENDS:=+libubox +libopenssl-1.1
  ABI_VERSION:=$(PKG_VERSION)
endef

TARGET_CFLAGS := -I$(STAGING_DIR)/usr/include/openssl-1.1 $(TARGET_CFLAGS)
TARGET_LDFLAGS := -L$(STAGING_DIR)/usr/lib/openssl-1.1 $(TARGET_LDFLAGS)

define Package/libustream-openssl-1.1/install
	$(INSTALL_DIR) $(1)/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libustream-ssl.so $(1)/lib/
endef

$(eval $(call BuildPackage,libustream-openssl-1.1))
