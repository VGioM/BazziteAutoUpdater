#!/usr/bin/bash
# Désinstalle NuitPC.
set -u
sudo systemctl disable --now nuitpc-update.timer nuitpc-poweroff.timer 2>/dev/null
sudo rm -f /etc/systemd/system/nuitpc-* /usr/local/bin/nuitpc-job /usr/local/bin/nuitpc-helper \
    /etc/polkit-1/rules.d/49-nuitpc.rules
sudo rm -rf /etc/nuitpc /var/lib/nuitpc
sudo systemctl daemon-reload
rm -f "$HOME/.local/bin/nuitpc" "$HOME/.local/share/applications/nuitpc.desktop" \
    "$HOME/.config/autostart/nuitpc-notify.desktop"
echo "NuitPC désinstallé (journal conservé : /var/log/nuitpc.log)."
