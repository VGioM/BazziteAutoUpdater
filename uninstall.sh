#!/usr/bin/bash
# Désinstalle BazziteAutoUpdater.
set -u
sudo systemctl disable --now bazzite-autoupdater-update.timer bazzite-autoupdater-poweroff.timer 2>/dev/null
sudo systemctl disable bazzite-autoupdater-wake.service 2>/dev/null
sudo rm -f /etc/systemd/system/bazzite-autoupdater-* /usr/local/bin/bazzite-autoupdater-job /usr/local/bin/bazzite-autoupdater-helper \
    /etc/polkit-1/rules.d/49-bazzite-autoupdater.rules
sudo rm -rf /etc/bazzite-autoupdater /var/lib/bazzite-autoupdater
sudo systemctl daemon-reload
rm -f "$HOME/.local/bin/bazzite-autoupdater" "$HOME/.local/share/applications/bazzite-autoupdater.desktop" \
    "$HOME/.config/autostart/bazzite-autoupdater-notify.desktop"
echo "BazziteAutoUpdater désinstallé (journal conservé : /var/log/bazzite-autoupdater.log)."
