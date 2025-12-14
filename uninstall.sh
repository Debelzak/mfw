#!/bin/bash
set -e

### CONSTANTS ###
SERVICE="mfw"
BIN="/usr/local/bin/mfw"
STATE_DIR="/etc/mfw"
SERVICE_FILE="/etc/systemd/system/mfw.service"

### CHECK ROOT ###
if [[ "$EUID" -ne 0 ]]; then
  echo "Execute as root (sudo)"
  exit 1
fi

cleanup_iptables() {
  echo "[1/7] Cleaning iptables rules"

  # NAT
  if iptables -t nat -L MFW_PREROUTING &>/dev/null; then
    iptables -t nat -D PREROUTING -j MFW_PREROUTING 2>/dev/null || true
    iptables -t nat -F MFW_PREROUTING
    iptables -t nat -X MFW_PREROUTING
    echo "  ✔ nat/MFW_PREROUTING removed"
  else
    echo "  ↪ nat/MFW_PREROUTING not found"
  fi

  # FILTER
  if iptables -L MFW_FORWARD &>/dev/null; then
    iptables -D FORWARD -j MFW_FORWARD 2>/dev/null || true
    iptables -F MFW_FORWARD
    iptables -X MFW_FORWARD
    echo "  ✔ filter/MFW_FORWARD removed"
  else
    echo "  ↪ filter/MFW_FORWARD not found"
  fi
}

echo "== Uninstalling MFW =="
echo

### IPTABLES ###
cleanup_iptables

### STOP SERVICE ###
if systemctl list-unit-files | grep -q "^$SERVICE\.service"; then
  echo "[2/7] Stopping service"
  systemctl stop "$SERVICE" 2>/dev/null || true

  echo "[3/7] Disabling service"
  systemctl disable "$SERVICE" 2>/dev/null || true
else
  echo "[2/7] Service not installed, skipping"
  echo "[3/7] Service not installed, skipping"
fi

### REMOVE SERVICE FILE ###
if [[ -f "$SERVICE_FILE" ]]; then
  echo "[4/7] Removing systemd service file"
  rm -f "$SERVICE_FILE"
else
  echo "[4/7] Service file not found, skipping"
fi

### REMOVE BINARY ###
if [[ -f "$BIN" ]]; then
  echo "[5/7] Removing binary"
  /bin/rm -rf "$STATE_DIR"
else
  echo "[5/7] Binary not found, skipping"
fi

### REMOVE STATE ###
if [[ -d "$STATE_DIR" ]]; then
  echo "[6/7] State directory found"
  read -rp "Remove $STATE_DIR ? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    /bin/rm -rf "$STATE_DIR"
    echo "  ✔ State removed"
  else
    echo "  ↪ State preserved"
  fi
else
  echo "[6/7] State directory not found, skipping"
fi

### SYSTEMD RELOAD ###
echo "[7/7] Reloading systemd"
systemctl daemon-reexec
systemctl daemon-reload

echo
echo "== MFW fully uninstalled =="
