include $(TOPDIR)/rules.mk

PKG_NAME:=libnghttp2
PKG_VERSION:=1.27.0
PKG_RELEASE:=1

PKG_SOURCE:=nghttp2-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/nghttp2/nghttp2/releases/download/v$(PKG_VERSION)/
PKG_HASH:=3d8fe1fe2ea8631343fb58c4d241e554758e0c56a7146118c130eae1c2312bc5
CMAKE_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/nghttp2-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Eneas Queiroz <euqueiroz@yahoo.com.br>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libnghttp2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=HTTP/2 C Library
  DEPENDS:=
  ABI_VERSION:=$(PKG_VERSION)
endef

define Package/libnghttp2/description
  This is an implementation of the Hypertext Transfer Protocol version 2 in C.
  The framing layer of HTTP/2 is implemented as a reusable C library.
endef

CONFIGURE_ARGS += \
       --enable-lib-only
CMAKE_OPTIONS += \
	-DENABLE_LIB_ONLY=TRUE

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) -P -R $(PKG_INSTALL_DIR)/usr/include/. $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libnghttp2/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libnghttp2))
