#!/bin/bash

# 修改默认IP
sed -i 's/192.168.1.1/192.168.123.1/g' package/base-files/files/bin/config_generate

# profile
sed -i 's#\\u@\\h:\\w\\\$#\\[\\e[32;1m\\][\\u@\\h\\[\\e[0m\\] \\[\\033[01;34m\\]\\W\\[\\033[00m\\]\\[\\e[32;1m\\]]\\[\\e[0m\\]\\\$#g' package/base-files/files/etc/profile
sed -ri 's/(export PATH=")[^"]*/\1%PATH%:\/opt\/bin:\/opt\/sbin:\/opt\/usr\/bin:\/opt\/usr\/sbin/' package/base-files/files/etc/profile
sed -i '/PS1/a\export TERM=xterm-color' package/base-files/files/etc/profile

# TTYD
sed -i 's/services/system/g' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i '3 a\\t\t"order": 50,' feeds/luci/applications/luci-app-ttyd/root/usr/share/luci/menu.d/luci-app-ttyd.json
sed -i 's/procd_set_param stdout 1/procd_set_param stdout 0/g' feeds/packages/utils/ttyd/files/ttyd.init
sed -i 's/procd_set_param stderr 1/procd_set_param stderr 0/g' feeds/packages/utils/ttyd/files/ttyd.init

# bash
sed -i 's#ash#bash#g' package/base-files/files/etc/passwd
sed -i '\#export ENV=/etc/shinit#a export HISTCONTROL=ignoredups' package/base-files/files/etc/profile
mkdir -p files/root
curl -so files/root/.bash_profile https://git.kejizero.online/zhao/files/raw/branch/main/root/.bash_profile
curl -so files/root/.bashrc https://git.kejizero.online/zhao/files/raw/branch/main/root/.bashrc

# Nginx
sed -i "s/large_client_header_buffers 2 1k/large_client_header_buffers 4 32k/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i "s/client_max_body_size 128M/client_max_body_size 2048M/g" feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tclient_body_buffer_size 8192M;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/client_max_body_size/a\\tserver_names_hash_bucket_size 128;' feeds/packages/net/nginx-util/files/uci.conf.template
sed -i '/ubus_parallel_req/a\        ubus_script_timeout 600;' feeds/packages/net/nginx/files-luci-support/60_nginx-luci-support
sed -ri "/luci-webui.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations
sed -ri "/luci-cgi_io.socket/i\ \t\tuwsgi_send_timeout 600\;\n\t\tuwsgi_connect_timeout 600\;\n\t\tuwsgi_read_timeout 600\;" feeds/packages/net/nginx/files-luci-support/luci.locations

# uwsgi
sed -i 's,procd_set_param stderr 1,procd_set_param stderr 0,g' feeds/packages/net/uwsgi/files/uwsgi.init
sed -i 's,buffer-size = 10000,buffer-size = 131072,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's,logger = luci,#logger = luci,g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i '$a cgi-timeout = 600' feeds/packages/net/uwsgi/files-luci-support/luci-*.ini
sed -i 's/threads = 1/threads = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/processes = 3/processes = 4/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini
sed -i 's/cheaper = 1/cheaper = 2/g' feeds/packages/net/uwsgi/files-luci-support/luci-webui.ini

# rpcd
sed -i 's/option timeout 30/option timeout 60/g' package/system/rpcd/files/rpcd.config
sed -i 's#20) \* 1000#60) \* 1000#g' feeds/luci/modules/luci-base/htdocs/luci-static/resources/rpc.js

# mwan3
sed -i 's/MultiWAN 管理器/负载均衡/g' feeds/luci/applications/luci-app-mwan3/po/zh_Hans/mwan3.po

# 更换为 ImmortalWrt Uboot 以及 Target
git clone -b openwrt-24.10 --single-branch --filter=blob:none https://github.com/immortalwrt/immortalwrt immortalwrt
rm -rf ./target/linux/rockchip
cp -rf immortalwrt/target/linux/rockchip target/linux/rockchip
curl -L -o target/linux/rockchip/patches-6.6/014-rockchip-add-pwm-fan-controller-for-nanopi-r2s-r4s.patch https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/PATCH/kernel/rockchip/014-rockchip-add-pwm-fan-controller-for-nanopi-r2s-r4s.patch
curl -L -o target/linux/rockchip/patches-6.6/702-general-rk3328-dtsi-trb-ent-quirk.patch https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/PATCH/kernel/rockchip/702-general-rk3328-dtsi-trb-ent-quirk.patch
curl -L -o target/linux/rockchip/patches-6.6/703-rk3399-enable-dwc3-xhci-usb-trb-quirk.patch https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/PATCH/kernel/rockchip/703-rk3399-enable-dwc3-xhci-usb-trb-quirk.patch
curl -L -o target/linux/rockchip/patches-6.6/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch https://github.com/immortalwrt/immortalwrt/raw/refs/heads/openwrt-23.05/target/linux/rockchip/patches-5.15/991-arm64-dts-rockchip-add-more-cpu-operating-points-for.patch
rm -rf package/boot/{rkbin,uboot-rockchip,arm-trusted-firmware-rockchip}
cp -rf immortalwrt/package/boot/uboot-rockchip package/boot/uboot-rockchip
cp -rf immortalwrt/package/boot/arm-trusted-firmware-rockchip package/boot/arm-trusted-firmware-rockchip
sed -i '/REQUIRE_IMAGE_METADATA/d' target/linux/rockchip/armv8/base-files/lib/upgrade/platform.sh
rm -rf immortalwrt

# Patch arm64 型号名称
curl -L -o target/linux/generic/hack-6.6/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/PATCH/kernel/arm/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch

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

# nginx
rm -rf feeds/packages/net/nginx
git clone https://github.com/sbwml/feeds_packages_net_nginx -b openwrt-24.10 feeds/packages/net/nginx

# IPv6 NAT
git clone https://github.com/sbwml/packages_new_nat6 package/nat6

# nginx - config
curl -s https://init2.cooluc.com/openwrt/nginx/luci.locations > feeds/packages/net/nginx/files-luci-support/luci.locations
curl -s https://init2.cooluc.com/openwrt/nginx/uci.conf.template > feeds/packages/net/nginx-util/files/uci.conf.template

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
popd

# Alist
git clone https://git.kejizero.online/zhao/luci-app-alist package/alist

# Mosdns
git clone https://git.kejizero.online/zhao/luci-app-mosdns.git -b v5 package/mosdns
git clone https://git.kejizero.online/zhao/v2ray-geodata.git package/v2ray-geodata

# 锐捷认证
git clone https://github.com/sbwml/luci-app-mentohust package/mentohust

# istoreos-files
git clone https://github.com/oppen321/istoreos-files package/istoreos-files

# Realtek 网卡 - R8168 & R8125 & R8126 & R8152 & R8101
rm -rf package/kernel/r8168 package/kernel/r8101 package/kernel/r8125 package/kernel/r8126
git clone https://git.kejizero.online/zhao/package_kernel_r8168 package/kernel/r8168
git clone https://git.kejizero.online/zhao/package_kernel_r8152 package/kernel/r8152
git clone https://git.kejizero.online/zhao/package_kernel_r8101 package/kernel/r8101
git clone https://git.kejizero.online/zhao/package_kernel_r8125 package/kernel/r8125
git clone https://git.kejizero.online/zhao/package_kernel_r8126 package/kernel/r8126

# Adguardhome
git_sparse_clone master https://github.com/kenzok8/openwrt-packages adguardhome luci-app-adguardhome

# smartdns
rm -rf feeds/{packages/netsmartdns,luci/applications/luci-app-smartdns}
git_sparse_clone master https://github.com/kenzok8/openwrt-packages smartdns luci-app-smartdns

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# Docker
rm -rf feeds/luci/applications/luci-app-dockerman
git clone https://git.kejizero.online/zhao/luci-app-dockerman -b 24.10 feeds/luci/applications/luci-app-dockerman
rm -rf feeds/packages/utils/{docker,dockerd,containerd,runc}
git clone https://git.kejizero.online/zhao/packages_utils_docker feeds/packages/utils/docker
git clone https://git.kejizero.online/zhao/packages_utils_dockerd feeds/packages/utils/dockerd
git clone https://git.kejizero.online/zhao/packages_utils_containerd feeds/packages/utils/containerd
git clone https://git.kejizero.online/zhao/packages_utils_runc feeds/packages/utils/runc
sed -i '/sysctl.d/d' feeds/packages/utils/dockerd/Makefile
pushd feeds/packages
    curl -s https://init.cooluc.com/openwrt/patch/docker/0001-dockerd-fix-bridge-network.patch | patch -p1
    curl -s https://init.cooluc.com/openwrt/patch/docker/0002-docker-add-buildkit-experimental-support.patch | patch -p1
    curl -s https://init.cooluc.com/openwrt/patch/docker/0003-dockerd-disable-ip6tables-for-bridge-network-by-defa.patch | patch -p1
popd

# UPnP
rm -rf feeds/{packages/net/miniupnpd,luci/applications/luci-app-upnp}
git clone https://git.kejizero.online/zhao/miniupnpd feeds/packages/net/miniupnpd -b v2.3.7
git clone https://git.kejizero.online/zhao/luci-app-upnp feeds/luci/applications/luci-app-upnp -b master

# Zero-package
git clone --depth=1 https://github.com/oppen321/Zero-package package/Zero-package

# 一键配置拨号
git clone --depth=1 https://github.com/sirpdboy/luci-app-netwizard package/luci-app-netwizard
sed -i 's/\("admin"\), *\("netwizard"\)/\1, "system", \2/g' package/luci-app-netwizard/luasrc/controller/*.lua

# 修改名称
sed -i 's/OpenWrt/ZeroWrt/' package/base-files/files/bin/config_generate

# Theme
# git clone --depth 1 https://github.com/sbwml/luci-theme-argon package/luci-theme-argon
# git clone https://github.com/sirpdboy/luci-theme-kucat package/luci-theme-kucat -b js
# curl -L -o package/luci-theme-argon/luci-theme-argon/htdocs/luci-static/argon/img/bg.webp https://git.kejizero.online/zhao/files/raw/branch/main/%20background/bg.webp
git clone --depth 1 https://github.com/oppen321/luci-theme-argon package/luci-theme-argon
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
git clone --depth 1 https://git.kejizero.online/zhao/luci-app-argon-config package/luci-app-argon-config

# default-settings
git clone --depth=1 -b dev https://github.com/oppen321/default-settings package/default-settings

# Lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# OpenAppFilter
git clone https://git.kejizero.online/zhao/OpenAppFilter --depth=1 package/OpenAppFilter

# luci-app-partexp
# git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp package/luci-app-partexp

# 进阶设置
# git clone https://github.com/sirpdboy/luci-app-advancedplus package/luci-app-advancedplus

# luci-app-webdav
git clone https://git.kejizero.online/zhao/luci-app-webdav package/new/luci-app-webdav

# unzip
rm -rf feeds/packages/utils/unzip
git clone https://github.com/sbwml/feeds_packages_utils_unzip feeds/packages/utils/unzip

# luci-app-modemband
git clone https://github.com/4IceG/luci-app-modemband package/luci-app-modemband

# frpc名称
sed -i 's,发送,Transmission,g' feeds/luci/applications/luci-app-transmission/po/zh_Hans/transmission.po
sed -i 's,frp 服务器,FRP 服务器,g' feeds/luci/applications/luci-app-frps/po/zh_Hans/frps.po
sed -i 's,frp 客户端,FRP 客户端,g' feeds/luci/applications/luci-app-frpc/po/zh_Hans/frpc.po

# NTP
sed -i 's/0.openwrt.pool.ntp.org/ntp1.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/1.openwrt.pool.ntp.org/ntp2.aliyun.com/g' package/base-files/files/bin/config_generate
sed -i 's/2.openwrt.pool.ntp.org/time1.cloud.tencent.com/g' package/base-files/files/bin/config_generate
sed -i 's/3.openwrt.pool.ntp.org/time2.cloud.tencent.com/g' package/base-files/files/bin/config_generate

# ZeroWrt选项菜单
mkdir -p files/bin
curl -L -o files/bin/ZeroWrt https://git.kejizero.online/zhao/files/raw/branch/main/bin/ZeroWrt
chmod +x files/bin/ZeroWrt
mkdir -p files/root
curl -L -o files/root/version.txt https://git.kejizero.online/zhao/files/raw/branch/main/bin/version.txt
chmod +x files/root/version.txt

# Adguardhome设置
mkdir -p files/etc
curl -L -o files/etc/AdGuardHome-dnslist.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-dnslist.yaml
chmod +x files/etc/AdGuardHome-dnslist.yaml
curl -L -o files/etc/AdGuardHome-mosdns.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-mosdns.yaml
chmod +x files/etc/AdGuardHome-mosdns.yaml
curl -L -o files/etc/AdGuardHome-dns.yaml https://git.kejizero.online/zhao/files/raw/branch/main/etc/AdGuardHome-dns.yaml
chmod +x files/etc/AdGuardHome-dns.yaml

# swapp
mkdir -p files/etc/sysctl.d
curl -L -o files/etc/sysctl.d/15-vm-swappiness.conf https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/15-vm-swappiness.conf
curl -L -o files/etc/sysctl.d/16-udp-buffer-size.conf https://raw.githubusercontent.com/oppen321/ZeroWrt/refs/heads/master/files/16-udp-buffer-size.conf
chmod +x files/etc/sysctl.d/15-vm-swappiness.conf
chmod +x files/etc/sysctl.d/16-udp-buffer-size.conf

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
