# Copyright (C) 2016-2026 OpenWrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-mwan3helper
PKG_VERSION:=1
PKG_RELEASE:=4

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=MWAN3 Helper contributors

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

PKGARCH:=all

define Package/luci-app-mwan3helper
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for MWAN3 Helper (chinaroute)
  DEPENDS:=+dnsmasq-full +ipset +iptables +ip +luci-compat +luci-lua-runtime
  PKGARCH:=all
endef

define Package/luci-app-mwan3helper/description
  LuCI support for MWAN3 Helper. Generates China/ISP IP set data and routes
  the domestic/GFW traffic through a dedicated gateway, with an optional
  anti-pollution DNS setup.
endef

define Package/luci-app-mwan3helper/conffiles
/etc/config/mwan3helper
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./luasrc $(PKG_BUILD_DIR)/
	$(CP) ./root $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-mwan3helper/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/mwan3helper
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/model/cbi/mwan3helper/*.lua $(1)/usr/lib/lua/luci/model/cbi/mwan3helper/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/mwan3helper
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/luasrc/view/mwan3helper/*.htm $(1)/usr/lib/lua/luci/view/mwan3helper/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/root/etc/config/mwan3helper $(1)/etc/config/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/root/etc/init.d/mwan3helper $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/mwan3helper
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/root/etc/mwan3helper/* $(1)/etc/mwan3helper/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/root/etc/mwan3helper/genipset.sh $(1)/etc/mwan3helper/

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/root/etc/uci-defaults/mwan3helper $(1)/etc/uci-defaults/

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/root/usr/share/rpcd/acl.d/luci-app-mwan3helper.json $(1)/usr/share/rpcd/acl.d/
endef

define Package/luci-app-mwan3helper/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || { \
	rm -f /tmp/luci-indexcache.*; \
	rm -rf /tmp/luci-modulecache/; \
	/etc/init.d/rpcd reload 2>/dev/null; \
	exit 0; \
}
endef

$(eval $(call BuildPackage,luci-app-mwan3helper))
