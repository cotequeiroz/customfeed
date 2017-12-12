#
# Copyright (C) 2016 The LuCI Team
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TYPE:=col
LUCI_BASENAME:=ssl-openssl-1.1

LUCI_TITLE:=LuCI with HTTPS support (OpenSSL-1.1 as SSL backend)
LUCI_DESCRIPTION:=LuCI with OpenSSL-1.1 as the SSL backend (libustream-openssl-1.1). \
 OpenSSL cmd tools (openssl-util) are used by uhttpd for SSL key generation \
 instead of the default px5g. (If px5g is installed, uhttpd will prefer that.)

LUCI_DEPENDS:=+luci +libustream-openssl-1.1 +openssl-util

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
