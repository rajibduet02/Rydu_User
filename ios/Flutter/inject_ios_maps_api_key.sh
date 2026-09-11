#!/bin/sh
# Bake GOOGLE_MAPS_IOS_API_KEY into the built Info.plist GMSApiKey when the
# source value is still empty / unsubstituted. Does not print the key.
set -e

PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
if [ ! -f "$PLIST" ]; then
  exit 0
fi

KEY="${GOOGLE_MAPS_IOS_API_KEY:-}"
SECRETS="${SRCROOT}/Flutter/MapsSecrets.xcconfig"
if [ -z "$KEY" ] && [ -f "$SECRETS" ]; then
  KEY="$(awk -F= '/^[[:space:]]*GOOGLE_MAPS_IOS_API_KEY[[:space:]]*=/{sub(/^[^=]*=/, ""); gsub(/[[:space:]]/, ""); print; exit}' "$SECRETS")"
fi

is_unresolved() {
  [ -z "$1" ] && return 0
  case "$1" in
    *'$('*|*GOOGLE_MAPS_IOS_API_KEY*|*YOUR_IOS*|*YOUR KEY*) return 0 ;;
  esac
  return 1
}

CURRENT="$(/usr/libexec/PlistBuddy -c 'Print :GMSApiKey' "$PLIST" 2>/dev/null || true)"

if ! is_unresolved "$CURRENT"; then
  echo "GMSApiKey already resolved in Info.plist"
  exit 0
fi

if is_unresolved "$KEY"; then
  echo "warning: GOOGLE_MAPS_IOS_API_KEY is missing or a placeholder. Debug builds fail at GMSServices init."
  exit 0
fi

if ! /usr/libexec/PlistBuddy -c "Set :GMSApiKey ${KEY}" "$PLIST" 2>/dev/null; then
  /usr/libexec/PlistBuddy -c "Add :GMSApiKey string ${KEY}" "$PLIST"
fi
echo "Injected GMSApiKey into Info.plist (value not logged)"
