#!/bin/sh
set -eu

# Finder launches do not receive the command-line launcher's soundbank override.
# Link the vendor's standard location to the packaged banks without copying them.
bank='@bank@'
destination='/Library/Application Support/Arobas Music/Soundbanks/com.arobas-music.soundbank.standard'

if [ -L "$destination" ]; then
  case "$(readlink "$destination")" in
    /nix/store/*-guitar-pro8-*/Library/Application\ Support/Arobas\ Music/Soundbanks/com.arobas-music.soundbank.standard)
      ;; # A link made by an earlier version of this helper may be updated.
    *)
      echo "Refusing to replace an unmanaged symlink: $destination" >&2
      exit 1
      ;;
  esac
elif [ -e "$destination" ]; then
  echo "Soundbanks already exist at $destination; leaving them untouched." >&2
  exit 1
fi

mkdir -p "$(dirname "$destination")"
ln -sfn "$bank" "$destination"
echo "Guitar Pro soundbanks linked to $bank"
