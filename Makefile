U_PREFIX=$(shell uname -n)
WG_DIR ?= etc/wireguard
WG_PEERS_DIR ?= etc/wireguard/peers
SYSCTL_DIR ?= etc/sysctl.d
SYSCTL_FILE ?= $(SYSCTL_DIR)/99-wireguard.conf
LOCAL_CONF=$(shell find . -mindepth 1 -maxdepth 1 -type d ! -path "*wireguard-install*" ! -path "*\.git*" -printf '%f\n')

.PHONY: diff

dirs:
	mkdir -p $(U_PREFIX)/$(WG_DIR)
	mkdir -p $(U_PREFIX)/$(WG_PEERS_DIR)
	mkdir -p $(U_PREFIX)/$(SYSCTL_DIR)

diff:
	sudo diff -u /$(WG_DIR)/wg0.conf $(U_PREFIX)/$(WG_DIR)/wg0.conf | colordiff
	sudo diff -u /$(WG_DIR)/private.key $(U_PREFIX)/$(WG_DIR)/private.key | colordiff
	sudo diff -u /$(WG_DIR)/public.key $(U_PREFIX)/$(WG_DIR)/public.key | colordiff
	sudo diff -u /$(WG_PEERS_DIR) $(U_PREFIX)/$(WG_PEERS_DIR) | colordiff
	sudo diff -u /$(SYSCTL_FILE) $(U_PREFIX)/$(SYSCTL_FILE) | colordiff

pull: dirs
	sudo cp /$(WG_DIR)/{wg0.conf,private.key,public.key} $(U_PREFIX)/$(WG_DIR)/
	sudo cp -rT /$(WG_PEERS_DIR) $(U_PREFIX)/$(WG_PEERS_DIR)
	sudo cp /$(SYSCTL_FILE) $(U_PREFIX)/$(SYSCTL_FILE)

push:
	sudo cp $(U_PREFIX)/$(WG_DIR)/{wg0.conf,private.key,public.key} /$(WG_DIR)/
	sudo cp -rT $(U_PREFIX)/$(WG_PEERS_DIR) /$(WG_PEERS_DIR)
	sudo cp $(U_PREFIX)/$(SYSCTL_FILE) /$(SYSCTL_FILE)

restart:
	sudo systemctl daemon-reload
	sudo systemctl restart wg-quick@wg0.service

install:
	sudo bash wireguard-install

client-install:
	sudo cp "$(LOCAL_CONF)/$(WG_PEERS_DIR)/$(U_PREFIX).conf /$(WG_DIR)/wg0.conf"
	sudo cp "$(LOCAL_CONF)/$(WG_PEERS_DIR)/$(U_PREFIX).private.key /$(WG_DIR)/private.key"
	sudo cp "$(LOCAL_CONF)/$(WG_PEERS_DIR)/$(U_PREFIX).public.key /$(WG_DIR)/public.key"

uninstall:
	sudo rm -f /$(WG_DIR)/{wg0.conf,private.key,public.key}
	sudo rm -rf /$(WG_PEERS_DIR)
	sudo rm -f /$(SYSCTL_FILE)
