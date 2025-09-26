#!/usr/bin/env sh

# Ensure this only runs on macOS
if [ "$(uname)" != "Darwin" ]; then
  exit 0
fi

set -e

# Desired key repeat settings captured from current machine
KEY_REPEAT=2
INITIAL_KEY_REPEAT=15
APPLE_PRESS_AND_HOLD=false

echo "Applying macOS key repeat defaults..."
defaults write -g KeyRepeat -int "$KEY_REPEAT"
defaults write -g InitialKeyRepeat -int "$INITIAL_KEY_REPEAT"
defaults write -g ApplePressAndHoldEnabled -bool "$APPLE_PRESS_AND_HOLD"

# Flush the preferences cache so changes are picked up sooner
killall -u "$USER" cfprefsd 2>/dev/null || true

echo "Set KeyRepeat=$KEY_REPEAT, InitialKeyRepeat=$INITIAL_KEY_REPEAT, ApplePressAndHoldEnabled=$APPLE_PRESS_AND_HOLD"
echo "Note: Some apps may need restart; a logout/login ensures system-wide effect."

