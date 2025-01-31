#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/luci2/bin/config_generate

# 移除要替换的包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,adguardhome,socat}
rm -rf feeds/packages/net/alist feeds/luci/applications/luci-app-alist
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# golong1.23依赖
#git clone --depth=1 https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# SSRP & Passwall
git clone https://git.kejizero.online/zhao/openwrt_helloworld.git package/helloworld -b v5

# IPv6 NAT
git clone https://github.com/sbwml/packages_new_nat6 package/nat6

# opkg
mkdir -p package/system/opkg/patches
curl -s https://init2.cooluc.com/openwrt/patch/opkg/900-opkg-download-disable-hsts.patch > package/system/opkg/patches/900-opkg-download-disable-hsts.patch

# luci-mod extra
pushd feeds/luci
    curl -s https://init2.cooluc.com/openwrt/patch/luci/0001-luci-mod-system-add-modal-overlay-dialog-to-reboot.patch | patch -p1
    curl -s https://init2.cooluc.com/openwrt/patch/luci/0002-luci-mod-status-displays-actual-process-memory-usage.patch | patch -p1
    curl -s https://init2.cooluc.com/openwrt/patch/luci/0003-luci-mod-status-storage-index-applicable-only-to-val.patch | patch -p1
    curl -s https://init2.cooluc.com/openwrt/patch/luci/0004-luci-mod-status-firewall-disable-legacy-firewall-rul.patch | patch -p1
    curl -s https://init2.cooluc.com/openwrt/patch/luci/0005-luci-mod-system-add-refresh-interval-setting.patch | patch -p1
    curl -s https://init2.cooluc.com/openwrt/patch/luci/0006-luci-mod-system-mounts-add-docker-directory-mount-po.patch | patch -p1

# Adguardhome
git_sparse_clone master https://github.com/kenzok8/openwrt-packages adguardhome luci-app-adguardhome

# smartdns
rm -rf feeds/{packages/netsmartdns,luci/applications/luci-app-smartdns}
git_sparse_clone master https://github.com/kenzok8/openwrt-packages smartdns luci-app-adguardhome

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone https://git.kejizero.online/zhao/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
git clone https://git.kejizero.online/zhao/luci-app-upnp feeds/luci/applications/luci-app-upnp -b master

# Adguardhome设置
mkdir -p files/etc
curl -L -o files/etc/AdGuardHome-dnslist.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-dnslist.yaml
chmod +x files/etc/AdGuardHome-dnslist.yaml
curl -L -o files/etc/AdGuardHome-mosdns.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-mosdns.yaml
chmod +x files/etc/AdGuardHome-mosdns.yaml
curl -L -o files/etc/AdGuardHome-dns.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-dns.yaml
chmod +x files/etc/AdGuardHome-dns.yaml

# default_set
mkdir -p files/etc/config
curl -L -o files/etc/config/default_dhcp.conf https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/default_dhcp.conf
curl -L -o files/etc/config/default_mosdns https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/default_mosdns
curl -L -o files/etc/config/default_smartdns https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/default_smartdns
curl -L -o files/etc/config/default_AdGuardHome https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/default_AdGuardHome
curl -L -o files/etc/config/default_passwall https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/default_passwall
curl -L -o files/etc/config/default_openclash https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/default_openclash
chmod +x files/etc/config/default_dhcp.conf
chmod +x files/etc/config/default_mosdns
chmod +x files/etc/config/default_smartdns
chmod +x files/etc/config/default_AdGuardHome
chmod +x files/etc/config/default_passwall
chmod +x files/etc/config/default_openclash

./scripts/feeds update -a
./scripts/feeds install -a
