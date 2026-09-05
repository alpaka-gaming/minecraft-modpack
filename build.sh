#!/usr/bin/env bash
set -e

VERSION="${1:-}"
DESTINATION="Alpaka-Modpack.mrpack"
SOURCE_DIR="src"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found." >&2
    exit 1
fi

# Update version in modrinth.index.json if provided
if [ -n "$VERSION" ]; then
    echo "Updating modrinth.index.json versionId to: $VERSION"
    if command -v jq >/dev/null 2>&1; then
        jq --arg v "$VERSION" '.versionId = $v' "$SOURCE_DIR/modrinth.index.json" > "$SOURCE_DIR/modrinth.index.json.tmp" && mv "$SOURCE_DIR/modrinth.index.json.tmp" "$SOURCE_DIR/modrinth.index.json"
    fi
fi

# Remove old package if exists
rm -f "$DESTINATION"

# Pack contents of src into root of .mrpack
echo "Packaging modpack into $DESTINATION..."
(cd "$SOURCE_DIR" && zip -q -r "../$DESTINATION" . -x "*.git*" "node_modules/*" ".editorconfig" "build.sh" "build.ps1")

# Also create versioned copy if version is provided
if [ -n "$VERSION" ]; then
    VERSIONED_DEST="Alpaka-Modpack-${VERSION}.mrpack"
    cp -f "$DESTINATION" "$VERSIONED_DEST"
    echo "Created versioned package: $VERSIONED_DEST"
fi

echo "Modpack packed successfully: $DESTINATION"
