#!/bin/bash
set -e

### VARIÁVEIS ###
BIN_DST="/usr/local/bin/mfw"

STATE_DIR="/etc/mfw"
STATE_FILE="$STATE_DIR/rules.conf"

SERVICE_FILE="/etc/systemd/system/mfw.service"

MFW_URL="https://raw.githubusercontent.com/debelzak/mfw/main/mfw"
LOCAL_MFW="./mfw"

### CHECK ROOT ###
if [[ "$EUID" -ne 0 ]]; then
  echo "Execute as root (sudo)"
  exit 1
fi

echo "== Installing MFW =="

### CHECK CURL ###
if ! command -v curl >/dev/null 2>&1; then
  echo "✖ curl not found. Please install curl first."
  exit 1
fi

### TEMP FILE ###
TMP_MFW="$(mktemp)"
trap '/bin/rm -f "$TMP_MFW"' EXIT

### GET MFW ###
if [[ -f "$LOCAL_MFW" ]]; then
  echo "[1/6] Using local ./mfw"
  cp "$LOCAL_MFW" "$TMP_MFW"
else
  echo "[1/6] Downloading mfw"
  curl -fsSL "$MFW_URL" -o "$TMP_MFW"
fi

### VALIDATE ###
if [[ ! -s "$TMP_MFW" ]]; then
  echo "✖ mfw binary is empty or invalid"
  exit 1
fi

chmod +x "$TMP_MFW"

### CREATE STATE ###
echo "[2/6] Creating state structure"
mkdir -p "$STATE_DIR"
touch "$STATE_FILE"
chmod 600 "$STATE_FILE"

### INSTALL BINARY ###
echo "[3/6] Installing binary"
install -m 755 "$TMP_MFW" "$BIN_DST"

### CREATE SERVICE ###
echo "[4/6] Creating systemd service"
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Minimal Forward Wrapper (MFW)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$BIN_DST reload
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

### INITIAL CONFIGURATION ###
echo "== Initial configuration =="
mfw configure

### SYSTEMD ###
echo "[5/6] Enabling service"
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable mfw

echo "[6/6] Starting service"
systemctl start mfw

echo
echo "== Installation finished =="
mfw help
