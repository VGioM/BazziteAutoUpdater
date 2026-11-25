#!/usr/bin/bash
# Installe NuitPC. À lancer en utilisateur normal (demande sudo pour la partie système).
set -eu
cd "$(dirname "$(readlink -f "$0")")"
[ "$(id -u)" -ne 0 ] || { echo "Lance ce script sans sudo."; exit 1; }
ME=$(id -un)
CONF=/etc/nuitpc/nuitpc.conf

echo "== Partie système (sudo)"
sudo install -d -m 755 /etc/nuitpc /var/lib/nuitpc
# On garde les réglages existants (ex. FIRMWARE_UPDATE) en cas de mise à jour de NuitPC.
if sudo test -f "$CONF"; then
    sudo sed -i "s/^NUITPC_USER=.*/NUITPC_USER=$ME/" "$CONF"
else
    printf 'NUITPC_USER=%s\nFIRMWARE_UPDATE=no\nBOOT_TIME=\n' "$ME" | sudo tee "$CONF" >/dev/null
fi
sudo chmod 644 "$CONF"
sudo install -m 755 -o root -g root root/nuitpc-job root/nuitpc-helper /usr/local/bin/
sudo install -m 644 -o root -g root systemd/nuitpc-update.service systemd/nuitpc-poweroff.service systemd/nuitpc-wake.service /etc/systemd/system/
sudo install -m 644 -o root -g root root/49-nuitpc.rules /etc/polkit-1/rules.d/
sudo touch /var/log/nuitpc.log && sudo chmod 644 /var/log/nuitpc.log
sudo restorecon -R /usr/local/bin/nuitpc-* /etc/systemd/system/nuitpc-* /etc/polkit-1/rules.d/49-nuitpc.rules 2>/dev/null || true
sudo systemctl daemon-reload
sudo systemctl enable --now nuitpc-wake.service

echo "== Partie utilisateur"
install -D -m 755 user/nuitpc "$HOME/.local/bin/nuitpc"
install -d "$HOME/.local/share/applications" "$HOME/.config/autostart"
sed "s|%h|$HOME|" user/nuitpc.desktop > "$HOME/.local/share/applications/nuitpc.desktop"
sed "s|%h|$HOME|" user/nuitpc-notify.desktop > "$HOME/.config/autostart/nuitpc-notify.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "NuitPC installé : cherche « NuitPC » dans le menu des applications."
