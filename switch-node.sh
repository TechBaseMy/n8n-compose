#!/bin/bash

version=$1
if [ -z "$version" ]; then
  echo "Usage: . switch-node <version>"
  echo "Available versions:"
  echo "  16 (Node.js v16.x)"
  echo "  18 (Node.js v18.x)"
  echo "  21 (Node.js v21.x)"
  echo "  22 (Node.js v22.x - default)"
  return 1 2>/dev/null || exit 1
fi

# Map short version to path
case "$version" in
  16) 
    TARGET="/opt/node-16.20.2"
    ;;
  18) 
    TARGET="/opt/node-18.20.2"
    ;;
  21) 
    TARGET="/opt/node-21.7.2"
    ;;
  22) 
    TARGET="/usr/local"
    ;;
  *)
    echo "Unsupported version: $version"
    echo "Supported versions: 16, 18, 21, 22"
    return 1 2>/dev/null || exit 1
    ;;
esac

# Check if target exists
if [ ! -d "$TARGET/bin" ]; then
  echo "Node.js version directory not found at $TARGET"
  return 1 2>/dev/null || exit 1
fi

echo "Switching to Node $version..."

# Create user-specific bin directory if it doesn't exist
mkdir -p /home/node/bin

# Create symlinks in user's bin directory
ln -sf "$TARGET/bin/node" /home/node/bin/node
ln -sf "$TARGET/bin/npm" /home/node/bin/npm
ln -sf "$TARGET/bin/npx" /home/node/bin/npx

# Remove old node paths from PATH and add new one
PATH=$(echo "$PATH" | sed 's|/home/node/bin:||g' | sed 's|:/home/node/bin||g')
export PATH="/home/node/bin:$PATH"

# Save the PATH to user's profile for future sessions
echo 'export PATH="/home/node/bin:$PATH"' > /home/node/.profile

# Test the switch
NODE_VERSION=$(node -v 2>/dev/null || echo "Error getting version")
echo "Successfully switched to Node $NODE_VERSION"
echo "This change is active in your current session and saved for future sessions"
