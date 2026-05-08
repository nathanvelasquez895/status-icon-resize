#!/bin/bash
# quick-settings-icon-size — installer
# Resizes the GNOME Shell quick settings panel icon (volume/profile picture)
# without affecting other status icons.
#
# Usage: ./status-icon-resize.sh [icon_size]
#   icon_size: optional, defaults to 32

set -e

ICON_SIZE=${1:-32}
UUID="panel-icon-size@local"
INSTALL_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"

echo "Installing $UUID with icon size ${ICON_SIZE}px..."

mkdir -p "$INSTALL_DIR"

# --- metadata.json ---
cat > "$INSTALL_DIR/metadata.json" << EOF
{
  "name": "Panel Icon Size",
  "description": "Resizes the quick settings panel icon to a visible size.",
  "uuid": "$UUID",
  "shell-version": ["45", "46", "47", "48"]
}
EOF

# --- extension.js ---
cat > "$INSTALL_DIR/extension.js" << EOF
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import St from 'gi://St';

const ICON_SIZE = ${ICON_SIZE};

function findIcons(actor, depth) {
    if (depth > 5) return;
    if (actor instanceof St.Icon) {
        actor.icon_size = ICON_SIZE;
    }
    if (actor.get_children) {
        actor.get_children().forEach(child => findIcons(child, depth + 1));
    }
}

export default class PanelIconSizeExtension {
    enable() {
        this._timeout = setTimeout(() => this._resize(), 1000);
    }

    disable() {
        if (this._timeout) {
            clearTimeout(this._timeout);
            this._timeout = null;
        }
    }

    _resize() {
        let qs = Main.panel.statusArea.quickSettings;
        if (!qs) return;
        findIcons(qs, 0);
    }
}
EOF

# --- Enable the extension ---
gnome-extensions enable "$UUID" 2>/dev/null || true

echo ""
echo "Done! Extension installed to $INSTALL_DIR"
echo "Icon size set to ${ICON_SIZE}px."
echo ""
echo "Log out and back in to apply."
echo "To change the size later, re-run: ./status-icon-resize.sh <size>"
echo "Example: ./status-icon-resize.sh 40"
