#!/usr/bin/bash
# Installe BazziteAutoUpdater. À lancer en utilisateur normal (demande sudo pour la partie système).
set -eu
cd "$(dirname "$(readlink -f "$0")")"
[ "$(id -u)" -ne 0 ] || { echo "Lance ce script sans sudo."; exit 1; }
ME=$(id -un)
CONF=/etc/bazzite-autoupdater/bazzite-autoupdater.conf

echo "== Partie système (sudo)"
sudo install -d -m 755 /etc/bazzite-autoupdater /var/lib/bazzite-autoupdater
# On garde les réglages existants (ex. FIRMWARE_UPDATE) en cas de mise à jour de BazziteAutoUpdater.
if sudo test -f "$CONF"; then
    sudo sed -i "s/^AUTOUPDATER_USER=.*/AUTOUPDATER_USER=$ME/" "$CONF"
else
    printf 'AUTOUPDATER_USER=%s\nFIRMWARE_UPDATE=no\nBOOT_TIME=\n' "$ME" | sudo tee "$CONF" >/dev/null
fi
sudo chmod 644 "$CONF"
sudo install -m 755 -o root -g root root/bazzite-autoupdater-job root/bazzite-autoupdater-helper /usr/local/bin/
sudo install -m 644 -o root -g root systemd/bazzite-autoupdater-update.service systemd/bazzite-autoupdater-poweroff.service systemd/bazzite-autoupdater-wake.service /etc/systemd/system/
sudo install -m 644 -o root -g root root/49-bazzite-autoupdater.rules /etc/polkit-1/rules.d/
sudo touch /var/log/bazzite-autoupdater.log && sudo chmod 644 /var/log/bazzite-autoupdater.log
sudo restorecon -R /usr/local/bin/bazzite-autoupdater-* /etc/systemd/system/bazzite-autoupdater-* /etc/polkit-1/rules.d/49-bazzite-autoupdater.rules 2>/dev/null || true
sudo systemctl daemon-reload
sudo systemctl enable --now bazzite-autoupdater-wake.service

echo "== Partie utilisateur"
install -D -m 755 user/bazzite-autoupdater "$HOME/.local/bin/bazzite-autoupdater"
install -d "$HOME/.local/share/applications" "$HOME/.config/autostart"
sed "s|%h|$HOME|" user/bazzite-autoupdater.desktop > "$HOME/.local/share/applications/bazzite-autoupdater.desktop"
sed "s|%h|$HOME|" user/bazzite-autoupdater-notify.desktop > "$HOME/.config/autostart/bazzite-autoupdater-notify.desktop"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

echo "BazziteAutoUpdater installé : cherche « BazziteAutoUpdater » dans le menu des applications."
