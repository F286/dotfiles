#!/usr/bin/env sh

# Ensure this only runs on macOS
if [ "$(uname)" != "Darwin" ]; then
  exit 0
fi

set -e

# Goal: Trackpad uses natural scrolling; Mouse uses traditional (non-natural)
TRACKPAD_NATURAL=true
MOUSE_NATURAL=false

echo "Applying macOS scroll direction: trackpad=natural, mouse=normal..."

# Trackpad: global natural scrolling preference
defaults write -g com.apple.swipescrolldirection -bool "$TRACKPAD_NATURAL"
# Also set currentHost variant for completeness on some macOS versions
defaults -currentHost write -g com.apple.swipescrolldirection -bool "$TRACKPAD_NATURAL" 2>/dev/null || true

# Mouse: many macOS versions honor a separate key for mice
# If present, this overrides the global trackpad setting for mouse devices
defaults write -g com.apple.mouse.swipescrolldirection -bool "$MOUSE_NATURAL" 2>/dev/null || true
defaults -currentHost write -g com.apple.mouse.swipescrolldirection -bool "$MOUSE_NATURAL" 2>/dev/null || true

# Flush the preferences cache so changes are picked up sooner
killall -u "$USER" cfprefsd 2>/dev/null || true

echo "Scroll direction set. Current values:"
printf "  NSGlobalDomain com.apple.swipescrolldirection (trackpad): "; defaults read -g com.apple.swipescrolldirection 2>/dev/null || echo "<unset>"
printf "  NSGlobalDomain com.apple.mouse.swipescrolldirection (mouse): "; defaults read -g com.apple.mouse.swipescrolldirection 2>/dev/null || echo "<unset>"
printf "  CurrentHost com.apple.swipescrolldirection: "; defaults -currentHost read -g com.apple.swipescrolldirection 2>/dev/null || echo "<unset>"
printf "  CurrentHost com.apple.mouse.swipescrolldirection: "; defaults -currentHost read -g com.apple.mouse.swipescrolldirection 2>/dev/null || echo "<unset>"

echo "Note: If mouse-specific key is <unset> on your macOS version, the global setting may apply to both devices. Toggling the setting once in System Settings can create the separate key."

