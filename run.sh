#!/bin/bash


SYSCTL_CONF_FILE="/etc/sysctl.conf"
HOSTAPD_CONF_FILE="/etc/hostapd/hostapd.conf"
DHCPCD_CONF_FILE="/etc/dhcpcd.conf"
DNSMASQ_CONF_FILE="/etc/dnsmasq.conf"

SSID="MY-NETWORK"
WPA_PASSPHRASE="MY-PASSPHRASE"


sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
apt-get -y dist-upgrade

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo npm install -g cowsay 
cowsay -f tux "Linux is awesome!"

touch /ssh
apt-get install -y hostapd

touch $HOSTAPD_CONF_FILE
cat > $HOSTAPD_CONF_FILE <<- EOM
interface=wlan0
ssid=$SSID
hw_mode=g
channel=7
ht_capab=[HT40][SHORT-GI-20][DSSS_CCK-40]
wmm_enabled=0
macaddr_acl=0
auth_algs=1
wpa=2
ignore_broadcast_ssid=0
wpa_passphrase=$WPA_PASSPHRASE
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOM
HOSTAPD_DEFAULTS_FILE="/etc/default/hostapd"

echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> $HOSTAPD_DEFAULTS_FILE
apt-get install -y dnsmasq

cat >> $DHCPCD_CONF_FILE <<- EOM
interface wlan0
static ip_address=192.168.2.2
static routers=192.168.2.2
static domain_name_servers=8.8.8.8
EOM

cat >> $DNSMASQ_CONF_FILE <<- EOM
interface=wlan0
domain-needed
bogus-priv
dhcp-range=192.168.2.1,192.168.2.250,12h
EOM

echo "net.ipv4.ip_forward=1" >> $SYSCTL_CONF_FILE
iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
apt-get install -y iptables-persistent

